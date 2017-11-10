//
//  Delaunay.swift
//  ARKitExample
//
//  Created by Yoo Seok Kim on 2017. 11. 8..
//  Copyright © 2017년 Apple. All rights reserved.
//

import ARKit
import Foundation

class Delaunay {
    
    /* 다른 모든 삼각형들을 포함할 수 있는 convex hull 생성 */
    fileprivate class func supertriangle(_ vertices: [HTFeatureVertex]) -> [HTFeatureVertex] {
        var xmin = Double(Int32.max)
        var ymin = Double(Int32.max)
        var xmax = -Double(Int32.max)
        var ymax = -Double(Int32.max)
        
        for i in 0..<vertices.count {
            if vertices[i].vertex.x < xmin { xmin = vertices[i].vertex.x }
            if vertices[i].vertex.x > xmax { xmax = vertices[i].vertex.x }
            if vertices[i].vertex.y < ymin { ymin = vertices[i].vertex.y }
            if vertices[i].vertex.y > ymax { ymax = vertices[i].vertex.y }
        }
        
        let dx = xmax - xmin
        let dy = ymax - ymin
        let dmax = max(dx, dy)
        let xmid = xmin + dx * 0.5
        let ymid = ymin + dy * 0.5
        
        let v1 = Vertex(x: xmid - 20 * dmax, y: ymid - dmax)
        let v2 = Vertex(x: xmid, y: ymid + 20 * dmax)
        let v3 = Vertex(x: xmid + 20 * dmax, y: ymid - dmax)
        
        return [
            HTFeatureVertex(vertex: v1),
            HTFeatureVertex(vertex: v2),
            HTFeatureVertex(vertex: v3),
        ]
    }
    
    /* 세 점을 통해 circumcircle 구하는 함수 */
    fileprivate class func circumcircle(i: HTFeatureVertex, j: HTFeatureVertex, k: HTFeatureVertex) -> Circumcircle {
        let x1 = i.vertex.x
        let y1 = i.vertex.y
        let x2 = j.vertex.x
        let y2 = j.vertex.y
        let x3 = k.vertex.x
        let y3 = k.vertex.y
        let xc: Double
        let yc: Double
        
        let fabsy1y2 = abs(y1 - y2)
        let fabsy2y3 = abs(y2 - y3)
        
        if fabsy1y2 < Double.ulpOfOne {
            let m2 = -((x3 - x2) / (y3 - y2))
            let mx2 = (x2 + x3) / 2
            let my2 = (y2 + y3) / 2
            xc = (x2 + x1) / 2
            yc = m2 * (xc - mx2) + my2
        } else if fabsy2y3 < Double.ulpOfOne {
            let m1 = -((x2 - x1) / (y2 - y1))
            let mx1 = (x1 + x2) / 2
            let my1 = (y1 + y2) / 2
            xc = (x3 + x2) / 2
            yc = m1 * (xc - mx1) + my1
        } else {
            let m1 = -((x2 - x1) / (y2 - y1))
            let m2 = -((x3 - x2) / (y3 - y2))
            let mx1 = (x1 + x2) / 2
            let mx2 = (x2 + x3) / 2
            let my1 = (y1 + y2) / 2
            let my2 = (y2 + y3) / 2
            xc = (m1 * mx1 - m2 * mx2 + my2 - my1) / (m1 - m2)
            
            if fabsy1y2 > fabsy2y3 {
                yc = m1 * (xc - mx1) + my1
            } else {
                yc = m2 * (xc - mx2) + my2
            }
        }
        
        let dx = x2 - xc
        let dy = y2 - yc
        let rsqr = dx * dx + dy * dy
        
        return Circumcircle(HTVertex1: i, HTVertex2: j, HTVertex3: k, x: xc, y: yc, rsqr: rsqr)
    }
    
    fileprivate class func dedup(_ edges: [HTFeatureVertex]) -> [HTFeatureVertex] {
        
        var e = edges
        var a: HTFeatureVertex?, b: HTFeatureVertex?, m: HTFeatureVertex?, n: HTFeatureVertex?
        
        var j = e.count
        while j > 0 {
            j -= 1
            b = j < e.count ? e[j] : nil
            j -= 1
            a = j < e.count ? e[j] : nil
            
            var i = j
            while i > 0 {
                i -= 1
                n = e[i]
                i -= 1
                m = e[i]
                
                if (a?.vertex == m?.vertex && b?.vertex == n?.vertex) ||
                    (a?.vertex == n?.vertex && b?.vertex == m?.vertex) {
                    e.removeSubrange(j...j + 1)
                    e.removeSubrange(i...i + 1)
                    break
                }
            }
        }
        
        return e
    }
    
    class func triangulate(_ vertices: [HTFeatureVertex]) -> [Triangle] {
        /* 점이 3개 미만이면 삼각형을 생성할 수 없음. */
        guard vertices.count >= 3 else { return [Triangle]() }
        
        let n = vertices.count
        var open = [Circumcircle]()
        var completed = [Circumcircle]()
        var edges = [HTFeatureVertex]()
        
        /* vertex array를 x좌표 순으로 정렬한다. */
        var _vertices = vertices.sorted { $0.vertex.x < $1.vertex.x }
        
        /* 다음으로, super triangle의 vertex들을 찾는다. */
        _vertices += supertriangle(_vertices)

        /* open completed list를 초기화한다.
         * open은 super triangle만 포함하고,
         * 아직 알고리즘을 진행하지 않았기 때문에 completed list는 빈 상태로 초기화한다. */
        open.append(circumcircle(i: _vertices[n],
                                 j: _vertices[n + 1],
                                 k: _vertices[n + 2]))

        /* mesh를 생성하기 위해 각 점을 Incrementally add */
        for i in 0..<n {
            edges.removeAll()

            /* 각각의 open triangle에 대해서, 현재 점이 이것의 circumcircle내부에 포함되는지 체크한다.
             * 만약 그렇다면, triangle을 제거하고, edges에 이 edge list를 추가한다.
             * 이것이 edge list에 추가하기 위한 해당 엣지들이다. */
            for j in (0..<open.count).reversed() {

                /* 만약 이 점이 triangle의 circumcircle의 오른쪽에 있다면,
                 * 이 triangle은 다시 체크할 필요가 없다. open list에서 이것을 삭제하고,
                 * completed list에 추가하고, 이후 작업을 스킵한다. */
                let dx = _vertices[i].vertex.x - open[j].x

                if dx > 0 && dx * dx > open[j].rsqr {
                    completed.append(open.remove(at: j))
                    continue
                }

                /* 만약 점이 circumcircle 밖에 있다면, 이 triangle은 스킵한다. */
                let dy = _vertices[i].vertex.y - open[j].y

                if dx * dx + dy * dy - open[j].rsqr > Double.ulpOfOne {
                    continue
                }

                /* triangle을 삭제하고, 삼각형의 edge들을 edge list에 추가한다. */
                edges += [
                    open[j].HTVertex1, open[j].HTVertex2,
                    open[j].HTVertex2, open[j].HTVertex3,
                    open[j].HTVertex3, open[j].HTVertex1
                ]

                open.remove(at: j)
            }

            /* 중복되는 edge가 있으면, 해당 edge를 제거한다.
             * 중복된다는 것은 공유를 의미한다. */
            edges = dedup(edges)
            /* 각각의 edge에 대해 새로운 triangle을 추가한다 */
            var j = edges.count
            while j > 0 {

                j -= 1
                let b = edges[j]
                j -= 1
                let a = edges[j]
                open.append(circumcircle(i: a, j: b, k: _vertices[i]))
            }
        }

        /* 나머지 open triangle들을 completed list에 추가하고, super triangle을 삭제한다. */
        completed += open

        let ignored: Set<Vertex> = [_vertices[n].vertex, _vertices[n + 1].vertex, _vertices[n + 2].vertex]

        let results = completed.flatMap { (circumCircle) -> Triangle? in

            let current: Set<Vertex> = [circumCircle.HTVertex1.vertex, circumCircle.HTVertex2.vertex, circumCircle.HTVertex3.vertex]
            let intersection = ignored.intersection(current)
            if intersection.count > 0 {
                return nil
            }

            return Triangle(vertex1: circumCircle.HTVertex1.originPosition,
                            vertex2: circumCircle.HTVertex2.originPosition,
                            vertex3: circumCircle.HTVertex3.originPosition)
        }
        
        return results
        
//        let _results = results.filter {
//            let vec1 = $0.vertex2 - $0.vertex1
//            let vec2 = $0.vertex3 - $0.vertex1
//
//            let normVec = vec1.normalized().cross(vec2.normalized())
//            let dot = normVec.normalized().dot(SCNVector3(0, 1, 0))
//
//            return abs(dot) < 0.15
//        }
//
//        _results.forEach {
//            let vec1 = $0.vertex2 - $0.vertex1
//            let vec2 = $0.vertex3 - $0.vertex1
//
//            let v11 = $0.vertex1
//            let v12 = $0.vertex2
//            let v13 = $0.vertex3
//
//            let normVec = vec1.normalized().cross(vec2.normalized())
//            let dot = normVec.normalized().dot(SCNVector3(0, 1, 0))
//
//        }
//
//        // (0, 1, 0)과의 dot product의 절대값이 0.2 이하? 수직이지 않을까
//        return _results
    }
    
}
