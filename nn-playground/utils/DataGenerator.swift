//
//  DataGenerator.swift
//  nn-playground
//
//  Created by Liuliet.Lee on 10/2/2020.
//  Copyright © 2020 Liuliet.Lee. All rights reserved.
//

import Foundation

public class DataGenerator {
    
    public enum T {
        case center
        case diag
    }
    
    public typealias DataType = (position: (x: Double, y: Double), label: Double)
    
    public static let dataScale = 10.0
    
    public static func centeredData() -> [DataType] {
        var data = [DataType]()
        for x in stride(from: -0.8, through: 0.8, by: 0.2) {
            for y in stride(from: -0.8, through: 0.8, by: 0.2) {
                let x = x * dataScale
                let y = y * dataScale
                
                if x * x + y * y < 3.5 * dataScale {
                    data.append(((x, y), 1.0))
                } else if x * x + y * y > 4.5 * dataScale {
                    data.append(((x, y), 0.0))
                }
            }
        }
        return data
    }
    
    public static func diagData() -> [DataType] {
        var data = [DataType]()
        for x in stride(from: -0.8, through: 0.8, by: 0.2) {
            for y in stride(from: -0.8, through: 0.8, by: 0.2) {
                let x = x * dataScale
                let y = y * dataScale

                if x == 0 || y == 0 { continue }
                data.append(((x, y), y * x < 0 ? 1.0 : 0.0))
            }
        }
        return data
    }

    public static func getTrainingData(_ type: T = .center) -> [DataType] {
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
