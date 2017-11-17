//
//  Delaunay.swift
//  ARKitExample
//
//  Created by Yoo Seok Kim on 2017. 11. 8..
//  Copyright © 2017년 Apple. All rights reserved.
//

import ARKit
import Foundation

enum TreeDirection {
    case root
    case left
    case right
}

class DCDelaunay {
    static let calculateCount = 8
    
    class func triangulateDivideAndConquer(_ vertices: [HTFeatureVertex]) -> [Triangle] {
        var triangles: [Triangle] = []
        var triangleLists: [[Triangle]] = []
        print(vertices.count)
        
        // nested function
        func DT(vertices: [HTFeatureVertex],
                currentDirection: TreeDirection,
                parentDirection: TreeDirection) -> [Triangle] {
            let count = vertices.count
            
            switch count {
            case 2: // do nothing
                return [Triangle]()
            case 3:
//                triangles.append(Triangle(vertex1: vertices[0].originPosition,
//                                 vertex2: vertices[1].originPosition,
//                                 vertex3: vertices[2].originPosition))
                return [Triangle(vertex1: vertices[0].originPosition,
                                 vertex2: vertices[1].originPosition,
                                 vertex3: vertices[2].originPosition)]
            default:
                let splitIndex = count / 2
                
                let left = Array(vertices[0..<splitIndex])
                let right = Array(vertices[splitIndex..<count])
                
                let ltList = DT(vertices: left, currentDirection: .left, parentDirection: currentDirection)
                let rtList = DT(vertices: right, currentDirection: .right, parentDirection: currentDirection)
//
//                print("left count: \(ltList.count)")
//                print("right count: \(rtList.count)")
//
                if ltList.count > calculateCount && rtList.count > calculateCount {
                    var leftNormalAvg = SCNVector3Zero
                    var rightNormalAvg = SCNVector3Zero
                    
                    ltList.forEach { leftNormalAvg += $0.normal }
                    rtList.forEach { rightNormalAvg += $0.normal }
                    
                    leftNormalAvg.normalize()
                    rightNormalAvg.normalize()
                    
                    print("left count: \(ltList.count)")
                    print("right count: \(rtList.count)")
                    print("normal's dot: \(leftNormalAvg.dot(rightNormalAvg))")
                    // 0.6 => 60도
                }
                
                let baseLR = findInitialBaseLR(left: left, right: right)
                
                var additionalTriangles: [Triangle] = []
                findNextLR(left: left, right: right, baseLR: baseLR, triangles: &additionalTriangles)
                
                var tList: [Triangle] = []
                tList += ltList
                tList += rtList
                tList += additionalTriangles
                return tList
            }
        }
        
        /* 점이 3개 미만이면 삼각형을 생성할 수 없음. */
        guard vertices.count >= 3 else { return [Triangle]() }
        
        /* vertex array를 x좌표 순으로 정렬한다. */
        let vertices = vertices.sorted { $0.vertex.x < $1.vertex.x }
        let result = DT(vertices: vertices, currentDirection: .root, parentDirection: .root)
//        return DT(vertices: vertices, currentDirection: .root, parentDirection: .root)
        
        return result
    }
    
    class func findNextLR(left: [HTFeatureVertex], right: [HTFeatureVertex], baseLR: Edge, triangles: inout [Triangle]) {
        func sortCandidates(vertices: [HTFeatureVertex], isLeft: Bool) -> [HTFeatureVertex] {
            var tuples: [(tan: Double, vertex: HTFeatureVertex)] = []
            
            if isLeft { // left
                vertices.forEach {
                    if det(central: baseLR.vertex1, start: baseLR.vertex2, end: $0) > 0 {
                        tuples.append((tan(central: baseLR.vertex1, start: baseLR.vertex2, end: $0), $0))
                    }
                }
            } else { // right
                vertices.forEach {
                    if det(central: baseLR.vertex2, start: $0, end: baseLR.vertex1) > 0 {
                        tuples.append((tan(central: baseLR.vertex2, start: baseLR.vertex1, end: $0), $0))
                    }
                }
            }
            
            tuples.sort { $0.tan < $1.tan }
            
            var results: [HTFeatureVertex] = []
            tuples.forEach { results.append($0.vertex) }
            
            return results
        }
        
        let leftCandidates = sortCandidates(vertices: left, isLeft: true)
        let rightCandidates = sortCandidates(vertices: right, isLeft: false)
        
        // Select L candidate
        var leftCandidate: HTFeatureVertex?
        
        for (i, candidate) in leftCandidates.enumerated() {
            if i == leftCandidates.count - 1 {
                leftCandidate = candidate
                break
            } else {
                var del = false
                for j in (i + 1)..<leftCandidates.count {
                    if isContain(baseLR: baseLR, currentCandidate: candidate, nextCandidate: leftCandidates[j]) {
                        removeTriangle(triangles: &triangles, at: Edge(vertex1: baseLR.vertex1, vertex2: candidate))
                        del = true
                        break
                    }
                }
                
                if del == false {
                    leftCandidate = candidate
                    break
                }
            }
        }
        
        // Select R candidate
        var rightCandidate: HTFeatureVertex?
        
        for (i, candidate) in rightCandidates.enumerated() {
            if i == rightCandidates.count - 1 {
                rightCandidate = candidate
                break
            }
            else {
                var del = false
                for j in (i + 1)..<rightCandidates.count {
                    if isContain(baseLR: baseLR, currentCandidate: candidate, nextCandidate: rightCandidates[j]) {
                        removeTriangle(triangles: &triangles, at: Edge(vertex1: baseLR.vertex2, vertex2: candidate))
                        del = true
                        break
                    }
                }
                
                if del == false {
                    rightCandidate = candidate
                    break
                }
            }
        }
        
        var isleftContainRight = false
        var newLR: Edge
        
        if let lc = leftCandidate, let rc = rightCandidate {
            isleftContainRight = isContain(baseLR: baseLR,
                                           currentCandidate: lc,
                                           nextCandidate: rc)
            
            if isleftContainRight {
                triangles.append(Triangle(vertex1: baseLR.vertex1.originPosition,
                                          vertex2: baseLR.vertex2.originPosition,
                                          vertex3: rc.originPosition))
                
                newLR = Edge(vertex1: baseLR.vertex1, vertex2: rc)
            } else {
                triangles.append(Triangle(vertex1: baseLR.vertex1.originPosition,
                                          vertex2: baseLR.vertex2.originPosition,
                                          vertex3: lc.originPosition))
                newLR = Edge(vertex1: lc, vertex2: baseLR.vertex2)
            }
        } else if let lc = leftCandidate {
            newLR = Edge(vertex1: lc, vertex2: baseLR.vertex2)
            triangles.append(Triangle(vertex1: baseLR.vertex1.originPosition,
                                      vertex2: baseLR.vertex2.originPosition,
                                      vertex3: lc.originPosition))
        } else if let rc = rightCandidate {
            newLR = Edge(vertex1: baseLR.vertex1, vertex2: rc)
            triangles.append(Triangle(vertex1: baseLR.vertex1.originPosition,
                                      vertex2: baseLR.vertex2.originPosition,
                                      vertex3: rc.originPosition))
        } else {
            return
        }
        findNextLR(left: left, right: right, baseLR: newLR, triangles: &triangles)
    }
    
    class private func findInitialBaseLR(left: [HTFeatureVertex],
                                         right: [HTFeatureVertex]) -> Edge {
        let leftPoints = left.sorted { $0.vertex.y < $1.vertex.y }
        let rightPoints = right.sorted { $0.vertex.y < $1.vertex.y }
        
        var Lmin = leftPoints.first!
        var Rmin = rightPoints.first!
        
        for rightPoint in rightPoints {
            if det(central: Lmin, start: Rmin, end: rightPoint) < 0 { Rmin = rightPoint }
            if rightPoint.vertex.y > Rmin.vertex.y && rightPoint.vertex.y > Lmin.vertex.y { break }
        }
        
        for leftPoint in leftPoints {
            if det(central: Rmin, start: Lmin, end: leftPoint) > 0 { Lmin = leftPoint }
            if leftPoint.vertex.y > Rmin.vertex.y && leftPoint.vertex.y > Lmin.vertex.y { break }
        }
        
        return Edge(vertex1: Lmin, vertex2: Rmin)
    }
    
    class private func det(central: HTFeatureVertex, start: HTFeatureVertex, end: HTFeatureVertex) -> Double {
        let startX = start.vertex.x - central.vertex.x
        let startY = start.vertex.y - central.vertex.y
        
        let endX = end.vertex.x - central.vertex.x
        let endY = end.vertex.y - central.vertex.y
        
        return startX * endY - startY * endX
    }
    
    class private func dot(central: HTFeatureVertex, start: HTFeatureVertex, end: HTFeatureVertex) -> Double {
        let startX = start.vertex.x - central.vertex.x
        let startY = start.vertex.y - central.vertex.y
        
        let endX = end.vertex.x - central.vertex.x
        let endY = end.vertex.y - central.vertex.y
        
        return startX * endX + startY * endY
    }
    
    class private func tan(central: HTFeatureVertex, start: HTFeatureVertex, end: HTFeatureVertex) -> Double {
        let startX = start.vertex.x - central.vertex.x
        let startY = start.vertex.y - central.vertex.y
        
        let endX = end.vertex.x - central.vertex.x
        let endY = end.vertex.y - central.vertex.y
        
        let dott = startX * endX + startY * endY
        let dist = sqrt((startX * startX + startY * startY) * (endX * endX + endY * endY))
        
        return -dott / dist
    }
    
    //if circumcircle of present point and baseLR points contain next point, return ture
    
    class private func isContain(baseLR: Edge,
                                 currentCandidate: HTFeatureVertex,
                                 nextCandidate: HTFeatureVertex) -> Bool {
        let p1 = baseLR.vertex1, p2 = baseLR.vertex2, p3 = currentCandidate
        
        let d1 = p1.vertex.x * p1.vertex.x + p1.vertex.y * p1.vertex.y
        let d2 = p2.vertex.x * p2.vertex.x + p2.vertex.y * p2.vertex.y
        let d3 = p3.vertex.x * p3.vertex.x + p3.vertex.y * p3.vertex.y
        
        let aux1 = d1 * (p3.vertex.y - p2.vertex.y) +
            d2 * (p1.vertex.y - p3.vertex.y) +
            d3 * (p2.vertex.y - p1.vertex.y)
        let aux2 = -(d1 * (p3.vertex.x - p2.vertex.x) +
            d2 * (p1.vertex.x - p3.vertex.x) +
            d3 * (p2.vertex.x - p1.vertex.x))
        let div = 2 * ((p1.vertex.x * (p3.vertex.y - p2.vertex.y)) +
            p2.vertex.x * (p1.vertex.y - p3.vertex.y) +
            p3.vertex.x * (p2.vertex.y - p1.vertex.y))
        
        if div == 0 { return false }
        
        // circumcircle
        let centerX = aux1 / div
        let centerY = aux2 / div
        let r = (centerX - p1.vertex.x) * (centerX - p1.vertex.x) + (centerY - p1.vertex.y) * (centerY - p1.vertex.y)
        
        let distX = nextCandidate.vertex.x - centerX
        let distY = nextCandidate.vertex.y - centerY
        let dist = distX * distX + distY * distY
        
        if r > dist { return true }
        else { return false }
    }
    
    class private func removeTriangle(triangles: inout [Triangle], at edge: Edge) {
        var removeIndices: [Int] = []
        
        for (index, triangle) in triangles.enumerated() {
            guard triangle.isContain(edge: edge) else {
                continue
            }
            
            removeIndices.append(index)
        }
        removeIndices.reversed().forEach {
            triangles.remove(at: $0)
        }
    }
    
}
