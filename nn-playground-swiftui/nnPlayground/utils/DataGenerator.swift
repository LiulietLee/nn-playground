//
//  DataGenerator.swift
//  nn-playground
//
//  Created by Liuliet.Lee on 10/2/2020.
//  Copyright © 2020 Liuliet.Lee. All rights reserved.
//

import Foundation

public struct Sample {
    var position: (x: Double, y: Double)
    var label: Double
}

struct IdentifiableSample: Identifiable {
    var id: Int
    var content: Sample
}

public class DataGenerator {
    
    public enum T {
        case center
        case diag
    }
    
    public static var noise = 0.3
    public static let dataScale = 5.0
    
    public static func centeredData() -> [Sample] {
        var data = [Sample]()
        for x in stride(from: -0.8, through: 0.8, by: 0.16) {
            for y in stride(from: -0.8, through: 0.8, by: 0.16) {
                let x = x * dataScale + Double.random(in: -1.0...1.0) * dataScale * noise * 0.1
                let y = y * dataScale + Double.random(in: -1.0...1.0) * dataScale * noise * 0.1
                
                if x * x + y * y < 0.3 * dataScale * dataScale {
                    data.append(Sample(position: (x, y), label: 1.0))
                } else if x * x + y * y > 0.5 * dataScale * dataScale {
                    data.append(Sample(position: (x, y), label: 0.0))
                }
            }
        }
        return data
    }
    
    public static func diagData() -> [Sample] {
        var data = [Sample]()
        for x in stride(from: -0.8, through: 0.8, by: 0.2) {
            for y in stride(from: -0.8, through: 0.8, by: 0.2) {
                let x = x * dataScale + Double.random(in: -1.0...1.0) * dataScale * noise * 0.1
                let y = y * dataScale + Double.random(in: -1.0...1.0) * dataScale * noise * 0.1

                if x == 0 || y == 0 { continue }
                data.append(Sample(position: (x, y), label: y * x < 0 ? 1.0 : 0.0))
            }
        }
        return data
    }

    public static func getTrainingData(_ type: T = .center) -> [Sample] {
        switch type {
        case .center:
            return centeredData()
        default:
            return diagData()
        }
    }
    
    public static func getImagePointSet(_ displayImageSize: Int) -> [[(x: Double, y: Double)]] {
        var res = [[(x: Double, y: Double)]](
            repeating: [(x: Double, y: Double)](
                repeating: (0.0, 0.0),
                count: displayImageSize
            ),
            count: displayImageSize
        )

        for intX in 0..<displayImageSize {
            for intY in 0..<displayImageSize {
                let x = dataScale * ((Double(intX) / Double(displayImageSize) * 2.0) - 1.0)
                let y = dataScale * ((Double(intY) / Double(displayImageSize) * 2.0) - 1.0)
                res[intY][intX] = (x, y)
            }
        }
        
        return res
    }
}