//
//  Evolv.swift
//  nn-playground
//
//  Created by Liuliet.Lee on 10/2/2020.
//  Copyright © 2020 Liuliet.Lee. All rights reserved.
//

import Foundation

public class Evolv {
    
    var desc = [2, 3, 3] {
        didSet {
            model = SequentialModel(desc)
        }
    }
    
    var model = SequentialModel()

    var data = [Sample]()
    
    let displayImageSize = 24
    var learningRate = 0.003
    var batchSize = 8
    
    public init() {
        model = SequentialModel(desc)
        data = DataGenerator.getTrainingData()
    }

    public func addLayer() {
        if desc.count < 5 {
            desc.append(2)
        }
    }
    
    public func dropLayer(_ id: Int = -1) {
        if desc.count > 1 {
            if id >= 0 {
                desc.remove(at: id)
            } else {
                desc.remove(at: desc.count + id)
            }
        }
    }
    
    public func toggleInputLayer(_ id: Int) {
        Transform.toggle(id)
        desc[0] = Transform.enabledTransform.count
    }
    
    public func addNeuron(at id: Int) {
        desc[id] = min(5, desc[id] + 1)
    }
    
    public func dropNeuron(at id: Int) {
        desc[id] = max(1, desc[id] - 1)
    }
    
    public func forwardGroup() -> ([[[[Double]]]], Double) {
        var res = [[[[Double]]]]()
        let fullDesc = desc + [1]
        for neu in fullDesc {
            res.append(
                [[[Double]]](
                    repeating: [[Double]](
                        repeating: [Double](
                            repeating: 0.0,
                            count: displayImageSize
                        ),
                        count: displayImageSize
                    ),
                    count: neu
                )
            )
        }
       
        let imagePoint = DataGenerator.getImagePointSet(displayImageSize)
        for i in 0..<displayImageSize {
            for j in 0..<displayImageSize {
                let p = imagePoint[i][j]
                let X = Transform.transform(p)
                let _ = model.forward(X)
                for m in 0..<desc[0] {
                    res[0][m][i][j] = model.input[0][m]
                }
                for l in 0..<desc.count {
                    for m in 0..<fullDesc[l + 1] {
                        res[l + 1][m][i][j] = model.layers[l].score[0][m]
                    }
                }
            }
        }

        var runningLoss = 0.0
       
        for i in 0..<data.count / batchSize {
            let X = (i * batchSize..<(i + 1) * batchSize).map { id in
                Transform.transform((self.data[id].position.x, self.data[id].position.y))[0]
            }
            let label = (i * batchSize..<(i + 1) * batchSize).map { id in
                [self.data[id].label]
            }

            let _ = model.forward(X)
            let loss = model.loss(label)
            runningLoss += loss
            model.backward(label)
            model.step(lr: learningRate, momentum: 0.99)
        }

        runningLoss /= Double(data.count)
       
        return (res, runningLoss)
    }
}
