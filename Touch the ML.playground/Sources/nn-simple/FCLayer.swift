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
    var leakyVal = 1e-4
    
    public var score = [[Double]]()
    var interScore = [[Double]]()
    
    public var param = [[Double]]()
    public var bias = [Double]()
    
    var vparam = [[[Double]]]()
    var vbias = [[Double]]()

    var mparam = [[[Double]]]()
    var mbias = [[Double]]()

    var dparam = [[[Double]]]()
    var dbias = [[Double]]()

    public init(inFeatures: Int, outFeatures: Int) {
        self.inFeatures = inFeatures
        self.outFeatures = outFeatures
        
        var paramIniter = [Double](repeating: 0.0, count: inFeatures * outFeatures)
        paramIniter.normalRandn(n: outFeatures + inFeatures)
        param = (0..<outFeatures).map { i in
            (0..<inFeatures).map { j in
                Double(paramIniter[i * inFeatures + j]) + 0.2
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
                    score[batch][i] = max(interScore[batch][i], leakyVal * interScore[batch][i])
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
            mbias = dbias
            vbias = dbias
            
            dparam = [[[Double]]](repeating: [[Double]](repeating: [Double](repeating: 0.0, count: inFeatures), count: outFeatures), count: batchSize)
            mparam = dparam
            vparam = dparam
        }
        
        for batch in 0..<batchSize {
            for i in 0..<outFeatures {
                if relu {
                    dbias[batch][i] += delta[batch][i] * (interScore[batch][i] >= 0.0 ? 1.0 : leakyVal)
                } else {
                    dbias[batch][i] += delta[batch][i]
                }
            }
            
            for i in 0..<outFeatures {
                for j in 0..<inFeatures {
                    if relu {
                        da[batch][j] += delta[batch][i] * param[i][j] * (interScore[batch][i] >= 0.0 ? 1.0 : leakyVal)
                    } else {
                        da[batch][j] += delta[batch][i] * param[i][j]
                    }
                }
            }
            
            for i in 0..<outFeatures {
                for j in 0..<inFeatures {
                    if relu {
                        dparam[batch][i][j] += delta[batch][i] * input[batch][j] * (interScore[batch][i] >= 0.0 ? 1.0 : leakyVal)
                    } else {
                        dparam[batch][i][j] += delta[batch][i] * input[batch][j]
                    }
                }
            }
        }
        
        return da
    }
    
    public func step(lr: Double, momentum: Double) {
        for batch in 0..<batchSize {
            for i in 0..<outFeatures {
                for j in 0..<inFeatures {
                    mparam[batch][i][j] = 0.9 * mparam[batch][i][j] + (1 - 0.9) * dparam[batch][i][j]
                    vparam[batch][i][j] = momentum * vparam[batch][i][j] + (1 - momentum) * dparam[batch][i][j] * dparam[batch][i][j]
                    param[i][j] -= lr * mparam[batch][i][j] / (sqrt(vparam[batch][i][j]) + 1e-8)
                    dparam[batch][i][j] = 0.0
                }
                mbias[batch][i] = 0.9 * mbias[batch][i] + (1 - 0.9) * dbias[batch][i]
                vbias[batch][i] = momentum * vbias[batch][i] + (1 - momentum) * dbias[batch][i] * dbias[batch][i]
                bias[i] -= lr * mbias[batch][i] / (sqrt(vbias[batch][i]) + 1e-8)
                dbias[batch][i] = 0.0
            }
        }
    }
}
