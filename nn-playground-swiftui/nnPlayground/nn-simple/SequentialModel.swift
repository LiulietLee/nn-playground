//
//  SSequential.swift
//  nn-playground
//
//  Created by Liuliet.Lee on 8/2/2020.
//  Copyright © 2020 Liuliet.Lee. All rights reserved.
//

import Foundation

public class SequentialModel {
    
    public var layers = [FCLayer]()
    
    public var score = [[Double]]()
    public var input = [[Double]]()
    
    public init(_ desc: [Int] = []) {
        if desc.isEmpty { return }
        for i in 0..<desc.count - 1 {
            layers.append(FCLayer(inFeatures: desc[i], outFeatures: desc[i + 1]))
        }
        layers.append(FCLayer(inFeatures: desc.last!, outFeatures: 1))
    }
    
    public init(_ layers: [FCLayer]) {
        self.layers = layers
    }
    
    public func forward(_ input: [[Double]]) -> [[Double]] {
        self.input = input
        var input = input
        for layer in layers {
            input = layer.forward(input)
        }
        score = input
        return score
    }
    
    public func backward(_ label: [[Double]]) {
        var r = d2.delta(score: score, label: label)
        for i in (0..<layers.count).reversed() {
            if i == 0 {
                r = layers[i].backward(input, delta: r)
            } else {
                r = layers[i].backward(layers[i - 1].score, delta: r)
            }
        }
    }
    
    public func step(lr: Double, momentum: Double) {
        for layer in layers {
            layer.step(lr: lr, momentum: momentum)
        }
    }
    
    public func loss(_ label: [[Double]]) -> Double {
        return d2.loss(score: score, label: label)
    }
}

extension SequentialModel {
    
    public class svm {
        public static var d = 1 - 0.618
       
        static func batchLoss(score: [Double], label: [Double]) -> Double {
            let maxi = label.indexOfMax()
           
            var loss = 0.0
            for i in 0..<score.count {
                if i != maxi {
                    loss += max(0, score[i] - score[maxi] + d)
                }
            }
           
            return loss
        }
       
        public static func loss(score: [[Double]], label: [[Double]]) -> Double {
            var loss = 0.0
            for i in 0..<score.count {
                loss += batchLoss(score: score[i], label: label[i])
            }
            return loss / Double(score.count)
        }
       
        static func batchDelta(score: [Double], label: [Double]) -> [Double] {
            var da = [Double](repeating: 0.0, count: score.count)
           
            let maxi = label.indexOfMax()
           
            for i in 0..<label.count {
                if i != maxi {
                    da[i] = score[i] - score[maxi] + d > 0 ? 1 : 0
                } else {
                    for j in 0..<label.count {
                        if j != maxi {
                            da[i] += score[j] - score[maxi] + d > 0 ? -1 : 0
                        }
                    }
                }
            }
           
            return da
       }
       
       public static func delta(score: [[Double]], label: [[Double]]) -> [[Double]] {
            var res = [[Double]]()
            for i in 0..<score.count {
                res.append(
                    batchDelta(score: score[i], label: label[i])
                )
            }
            return res
        }
    }
}

extension SequentialModel {
    public class d2 {
        public static func loss(score: [[Double]], label: [[Double]]) -> Double {
            var loss = 0.0
            for i in 0..<score.count {
                for j in 0..<score[0].count {
                    loss += (score[i][j] - label[i][j]) * (score[i][j] - label[i][j])
                }
            }
            return loss
        }
        
        public static func delta(score: [[Double]], label: [[Double]]) -> [[Double]] {
            var da = score
            for i in 0..<score.count {
                for j in 0..<score[0].count {
                    da[i][j] = -2.0 * (label[i][j] - score[i][j])
                }
            }
            return da
        }
    }
}

extension Array where Element == Double {
    public func indexOfMax() -> Int {
        var id = 0
        for i in 0..<count {
            if self[id] < self[i] {
                id = i
            }
        }
        return id
    }
    
    @discardableResult
    public mutating func normalRandn(sigma: Double = 1.0, mu: Double = 0.0, n: Int = 2) -> [Double] {
        let len = count - count % 2
        let scale = sqrt(2.0 / Double(n))
        
        for i in stride(from: 0, to: len, by: 2) {
            var x = 0.0, y = 0.0, rsq = 0.0, f = 0.0
            repeat {
                x = 2.0 * Double.random(in: 0.0..<1.0) - 1.0
                y = 2.0 * Double.random(in: 0.0..<1.0) - 1.0
                rsq = x * x + y * y
            } while rsq >= 1.0 || rsq == 0.0
            f = sqrt(-2.0 * log(rsq) / rsq)
            self[i] = (sigma * (x * f) + mu) * scale
            self[i + 1] = (sigma * (y * f) + mu) * scale
        }

        return self
    }
}
