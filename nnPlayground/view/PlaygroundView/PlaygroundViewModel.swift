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
            mainImage = visualImages[mainImageIndex.0][mainImageIndex.1]
        }
    }
    var runningLoss = 0.0
    var epochCount = 0
    
    var evolving = false
    let model = Evolv()
    let barrier = DispatchSemaphore(value: 0)

    var firstEvolv = true
    
    public init() {
        evolvOnce()
        mainImageIndex = (model.desc.count, 0)
        mainImage = visualImages[mainImageIndex.0][mainImageIndex.1]
    }
    
    public func evolvOnce(epoch: Int = 1) {
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
        epochCount = epoch
    }
    
    public func evolv() {
        DispatchQueue.global().async {
            for i in 0..<2000 {
                self.barrier.wait()
                self.evolvOnce(epoch: i)
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
                
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
    
    public func evolvToggle() {
        if evolving {
            evolvPause()
        } else {
            evolvBegin()
        }
        objectWillChange.send()
    }
}
