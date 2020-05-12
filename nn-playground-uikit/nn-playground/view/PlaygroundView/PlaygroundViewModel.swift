//
//  PlaygroundViewModel.swift
//  nnPlayground
//
//  Created by Liuliet.Lee on 22/2/2020.
//  Copyright © 2020 Liuliet.Lee. All rights reserved.
//

import UIKit

public class PlaygroundViewModel {
    let notice = NotificationCenter.default

    var visualImages = [[UIImage]]()
    var mainImage = UIImage()
    var mainImageIndex = (0, 0) {
        didSet {
            if mainImageIndex.0 < visualImages.count,
                mainImageIndex.1 < visualImages[mainImageIndex.0].count {
                mainImage = visualImages[mainImageIndex.0][mainImageIndex.1]
            }
        }
    }
    var runningLoss = 0.0
    var epochCount = 0
    
    var evolving = false
    let model = Evolv()
    let barrier = DispatchSemaphore(value: 0)

    var firstEvolv = true
    
    var learningRateScaler: Double {
        get { model.learningRate / 0.0001 }
        set {
            evolvStop()
            model.learningRate = newValue * 0.0001
            notice.post(name: Notification.Name("LearningRateUpdated"), object: nil)
        }
    }
    var batchSize: Double {
        get { Double(model.batchSize) }
        set {
            evolvStop()
            model.batchSize = Int(newValue)
            model.model = SequentialModel(model.desc)
            newModelGenerated()
        }
    }
    var dataNoise: Double {
        get { DataGenerator.noise }
        set {
            evolvStop()
            DataGenerator.noise = newValue
            model.data = DataGenerator.getTrainingData()
            model.model = SequentialModel(model.desc)
            newModelGenerated()
            notice.post(name: Notification.Name("SampleUpdated"), object: nil)
        }
    }
    
    public init() {
        newModelGenerated()
    }
    
    func newModelGenerated() {
        epochCount = 0
        mainImageIndex = (model.desc.count, 0)
        evolvOnce()
    }
    
    public func evolvOnce() {
        let (array, loss) = model.forwardGroup()
        
        for (j, layer) in array.enumerated() {
            if visualImages.count <= j {
                visualImages.append([])
            }
            for (k, imgArray) in layer.enumerated() {
                let pixels = makePixelSet(imgArray)
                let image = imageFromPixels(pixels)
                if visualImages[j].count <= k {
                    visualImages[j].append(image)
                } else {
                    visualImages[j][k] = image
                }
            }
        }
        
        mainImage = visualImages[mainImageIndex.0][mainImageIndex.1]
        runningLoss = loss
        epochCount += 1
        
        DispatchQueue.main.async {
            self.notice.post(name: Notification.Name("NewFrame"), object: nil)
        }
    }
    
    public func evolv() {
        DispatchQueue.global().async {
            while true {
                self.barrier.wait()
                self.evolvOnce()
                self.barrier.signal()
            }
        }
    }
    
    public func evolvBegin() {
        evolving = true
        if firstEvolv {
            evolv()
            firstEvolv = false
        }
        barrier.signal()
    }
    
    public func evolvPause() {
        evolving = false
        barrier.wait()
    }
    
    public func evolvStop() {
        if evolving {
            evolvPause()
        }
    }
    
    public func evolvRestart() {
        evolvStop()
        model.model = SequentialModel(model.desc)
        newModelGenerated()
    }
    
    public func evolvToggle() {
        if evolving {
            evolvPause()
        } else {
            evolvBegin()
        }
    }
}

extension PlaygroundViewModel {
    public func addLayer() {
        evolvStop()
        model.addLayer()
        newModelGenerated()
        notice.post(name: Notification.Name("ModelStructChanged"), object: nil)
    }
    
    public func dropLayer(_ id: Int = -1) {
        evolvStop()
        model.dropLayer(id)
        newModelGenerated()
        notice.post(name: Notification.Name("ModelStructChanged"), object: nil)
    }

    public func addNeuron(at id: Int) {
        evolvStop()
        model.addNeuron(at: id)
        newModelGenerated()
        notice.post(
            name: Notification.Name("LayerStructChanged"),
            object: nil,
            userInfo: ["id": id]
        )
    }
    
    public func dropNeuron(at id: Int) {
        evolvStop()
        model.dropNeuron(at: id)
        newModelGenerated()
        notice.post(
            name: Notification.Name("LayerStructChanged"),
            object: nil,
            userInfo: ["id": id]
        )
    }
    
    public func toggleInput(id: Int) {
        evolvStop()
        model.toggleInputLayer(id)
        newModelGenerated()
        notice.post(
            name: Notification.Name("LayerStructChanged"),
            object: nil,
            userInfo: ["id": 0]
        )
    }
}

extension PlaygroundViewModel {
    var viewHeight: CGFloat {
        CGFloat(model.desc.count * 100 + 170)
    }
    
    func rowWidth(_ i: Int) -> CGFloat {
        CGFloat((model.desc[i] - 1) * (50 + 20) + 50 + 48 * 2)
    }
}
