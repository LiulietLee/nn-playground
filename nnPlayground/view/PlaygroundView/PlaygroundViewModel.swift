//
//  PlaygroundViewModel.swift
//  nnPlayground
//
//  Created by Liuliet.Lee on 22/2/2020.
//  Copyright © 2020 Liuliet.Lee. All rights reserved.
//

import Combine
import UIKit

public class PlaygroundViewModel: ObservableObject {
    
    public let objectWillChange = PassthroughSubject<Void, Never>()
        
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
        get { model.learningRate / 0.00001 }
        set {
            evolvStop()
            model.learningRate = newValue * 0.00001
            newModelGenerated()
        }
    }
    var batchSize: Double {
        get { Double(model.batchSize) }
        set {
            evolvStop()
            model.batchSize = Int(newValue)
            newModelGenerated()
        }
    }
    var dataNoise: Double {
        get { DataGenerator.noise }
        set {
            evolvStop()
            DataGenerator.noise = newValue
            model.data = DataGenerator.getTrainingData(.center)
            newModelGenerated()
        }
    }
    
    public init() {
        newModelGenerated()
    }
    
    func newModelGenerated() {
        epochCount = 0
        mainImageIndex = (model.desc.count, 0)
        evolvOnce()
        objectWillChange.send()
    }
    
    public func evolvOnce() {
        let (array, loss) = model.forwardGroup()
        for (j, layer) in array.enumerated() {
            if visualImages.count <= j {
                visualImages.append([UIImage]())
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
            self.objectWillChange.send()
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
        model.model = SSequential(model.desc)
        newModelGenerated()
    }
    
    public func evolvToggle() {
        if evolving {
            evolvPause()
        } else {
            evolvBegin()
        }
        objectWillChange.send()
    }
}

extension PlaygroundViewModel {
    public func addLayer() {
        evolvStop()
        model.addLayer()
        newModelGenerated()
    }
    
    public func dropLayer(_ id: Int = -1) {
        evolvStop()
        model.dropLayer(id)
        newModelGenerated()
    }

    public func addNeuron(at id: Int) {
        evolvStop()
        model.addNeuron(at: id)
        newModelGenerated()
    }
    
    public func dropNeuron(at id: Int) {
        evolvStop()
        model.dropNeuron(at: id)
        newModelGenerated()
    }
    
    public func toggleInput(id: Int) {
        evolvStop()
        model.toggleInputLayer(id)
        newModelGenerated()
    }
}
