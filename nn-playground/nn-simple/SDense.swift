//
//  SDense.swift
//  nn-playground
//
//  Created by Liuliet.Lee on 8/2/2020.
//  Copyright © 2020 Liuliet.Lee. All rights reserved.
//

import Foundation

public class SDense {
    var inFeatures = 0
    var outFeatures = 0
    var batchSize = 1
    
    public var score = [[Double]]()
    var interScore = [[Double]]()
    
    var param = [[Double]]()
    var bias = [Double]()
    
    var vparam = [[[Double]]]()
    var vbias = [[Double]]()

    var mparam = [[[Double]]]()
    var mbias = [[Double]]()

    var dparam = [[[Double]]]()
    var dbias = [[Double]]()

    public init(inFeatures: Int, outFeatures: Int) {
        self.inFeatures = inFeatures
        self.outFeatures = outFeatures
        
        let paramIniter = NNArray(outFeatures, inFeatures).normalRandn(n: outFeatures + inFeatures)
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
                score[batch][i] = max(interScore[batch][i], 0.001 * interScore[batch][i])
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
                dbias[batch][i] += delta[batch][i] * (interScore[batch][i] >= 0.0 ? 1.0 : 0.001)
            }
            
            for i in 0..<outFeatures {
                for j in 0..<inFeatures {
                    da[batch][j] += (interScore[batch][i] >= 0.0 ? 1.0 : 0.001) * delta[batch][i] * param[i][j]
                }
            }
            
            for i in 0..<outFeatures {
                for j in 0..<inFeatures {
                    dparam[batch][i][j] += (interScore[batch][i] >= 0.0 ? 1.0 : 0.001) * delta[batch][i] * input[batch][j]
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
