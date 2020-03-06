//
//  SDense.swift
//  nn-playground
//
//  Created by Liuliet.Lee on 8/2/2020.
//  Copyright © 2020 Liuliet.Lee. All rights reserved.
//

import Foundation

public class FCLayer {
    var inFeatures = 0
    var outFeatures = 0
    var batchSize = 1
    var relu = true
    
    public var score = [[Double]]()
    var interScore = [[Double]]()
    
    public var param = [[Double]]()
    public var bias = [Double]()
    
    var dparam = [[[Double]]]()
    var dbias = [[Double]]()

    public init(inFeatures: Int, outFeatures: Int) {
        self.inFeatures = inFeatures
        self.outFeatures = outFeatures
        
        let paramIniter = NNArray(outFeatures, inFeatures).normalRandn(sigma: 0.5, mu: 0.2, n: outFeatures + inFeatures)
        param = (0..<outFeatures).map { i in
            (0..<inFeatures).map { j in
                Double(paramIniter[i, j])
            }
        }
        bias = [Double](repeating: 0.0, count: outFeatures)
    }
    
    public func forward(_ input: [[Double]]) -> [[Double]] {
        batchSize = input.count
        
        score = [[Double]](repeating: [Double](repeating: 0.0, count: outFeatures), count: batchSize)
        interScore = score
        
        for batch in 0..<batchSize {
            for i in 0..<outFeatures {
                for j in 0..<inFeatures {
                    interScore[batch][i] += param[i][j] * input[batch][j]
                }
                interScore[batch][i] += bias[i]
            }
            
            for i in 0..<outFeatures {
                if relu {
                    score[batch][i] = max(interScore[batch][i], 0.001 * interScore[batch][i])
                } else {
                    score[batch][i] = interScore[batch][i]
                }
            }
        }
        
        return score
    }
    
    public func backward(_ input: [[Double]], delta: [[Double]]) -> [[Double]] {
        batchSize = input.count
        var da = [[Double]](repeating: [Double](repeating: 0.0, count: input[0].count), count: input.count)
        
        if dparam.count != batchSize {
            dbias = [[Double]](repeating: [Double](repeating: 0.0, count: bias.count), count: batchSize)
            dparam = [[[Double]]](repeating: [[Double]](repeating: [Double](repeating: 0.0, count: inFeatures), count: outFeatures), count: batchSize)
        }
        
        for batch in 0..<batchSize {
            for i in 0..<outFeatures {
                if relu {
                    dbias[batch][i] += delta[batch][i] * (interScore[batch][i] >= 0.0 ? 1.0 : 0.001)
                } else {
                    dbias[batch][i] += delta[batch][i]
                }
            }
            
            for i in 0..<outFeatures {
                for j in 0..<inFeatures {
                    if relu {
                        da[batch][j] += delta[batch][i] * param[i][j] * (interScore[batch][i] >= 0.0 ? 1.0 : 0.001)
                    } else {
                        da[batch][j] += delta[batch][i] * param[i][j]
                    }
                }
            }
            
            for i in 0..<outFeatures {
                for j in 0..<inFeatures {
                    if relu {
                        dparam[batch][i][j] += delta[batch][i] * input[batch][j] * (interScore[batch][i] >= 0.0 ? 1.0 : 0.001)
                    } else {
                        dparam[batch][i][j] += delta[batch][i] * input[batch][j]
                    }
                }
            }
        }
        
        return da
    }
    
    public func step(lr: Double) {
        for i in 0..<outFeatures {
            for j in 0..<inFeatures {
                var der = 0.0
                for batch in 0..<batchSize {
                    der += dparam[batch][i][j]
                    dparam[batch][i][j] = 0
                }
                param[i][j] -= lr * der / Double(batchSize)
            }
        }
        
        for i in 0..<outFeatures {
            var der = 0.0
            for batch in 0..<batchSize {
                der += dbias[batch][i]
                dbias[batch][i] = 0
            }
            bias[i] -= lr * der / Double(batchSize)
        }
    }
}
