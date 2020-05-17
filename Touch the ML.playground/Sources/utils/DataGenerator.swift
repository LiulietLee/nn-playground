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
        case streak
        case linecut
        case spiral
    }
    
    public static var noise = 0.3
    public static let dataScale = 5.0
    public static var dataType = T.linecut
    
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
    
    public static func streakData() -> [Sample] {
        var data = [Sample]()
        for x in stride(from: -0.8, through: 0.8, by: 0.25) {
            for y in stride(from: -0.8, through: 0.8, by: 0.2) {
                let x = x * dataScale + Double.random(in: -1.0...1.0) * dataScale * noise * 0.1
                let y = y * dataScale + Double.random(in: -1.0...1.0) * dataScale * noise * 0.1
                
                var label = 1.0
                if y < x + dataScale * 0.6 && y > x - dataScale * 0.6 {
                    label = 0.0
                }

                data.append(Sample(position: (x, y), label: label))
            }
        }
        return data
    }
    
    public static func linecutData() -> [Sample] {
        var data = [Sample]()
        for x in stride(from: -0.8, through: 0.8, by: 0.2) {
            for y in stride(from: -0.8, through: 0.8, by: 0.2) {
                if x == y { continue }

                let x = x * dataScale + Double.random(in: -1.0...1.0) * dataScale * noise * 0.1
                let y = y * dataScale + Double.random(in: -1.0...1.0) * dataScale * noise * 0.1

                data.append(Sample(position: (x, y), label: x < y ? 1.0 : 0.0))
            }
        }
        return data
    }
    
    public static func spiralData() -> [Sample] {
        var data = [Sample]()
        let theta = Double.pi / 2
        
        for i in stride(from: 1.0, to: 5.0, by: 0.25) {
            var ang = i
            var x = i * sin(ang) + Double.random(in: -1.0...1.0) * dataScale * noise * 0.1
            var y = i * cos(ang) + Double.random(in: -1.0...1.0) * dataScale * noise * 0.1
            data.append(Sample(position: (x: x, y: y), label: 0.0))
            
            ang += theta
            x = i * sin(ang) + Double.random(in: -1.0...1.0) * dataScale * noise * 0.1
            y = i * cos(ang) + Double.random(in: -1.0...1.0) * dataScale * noise * 0.1
            data.append(Sample(position: (x: x, y: y), label: 0.0))

            ang += theta
            x = i * sin(ang) + Double.random(in: -1.0...1.0) * dataScale * noise * 0.1
            y = i * cos(ang) + Double.random(in: -1.0...1.0) * dataScale * noise * 0.1
            data.append(Sample(position: (x: x, y: y), label: 1.0))

            ang += theta
            x = i * sin(ang) + Double.random(in: -1.0...1.0) * dataScale * noise * 0.1
            y = i * cos(ang) + Double.random(in: -1.0...1.0) * dataScale * noise * 0.1
            data.append(Sample(position: (x: x, y: y), label: 1.0))
        }
        
        return data
    }

    public static func getTrainingData() -> [Sample] {
        switch dataType {
        case .center:
            return centeredData()
        case .linecut:
            return linecutData()
        default:
            return streakData()
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
    
    public static func nextType() {
        let typeArr: [T] = [.linecut, .streak, .center]
        for (idx, t) in typeArr.enumerated() {
            if t == dataType {
                dataType = typeArr[(idx + 1) % typeArr.count]
                return
            }
        }
    }
}
