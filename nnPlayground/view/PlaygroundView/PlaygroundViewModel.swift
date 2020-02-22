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
        
    var displayImage = UIImage()
    var runningLoss = 0.0
    var epochCount = 0
    
    var evolving = false
    let model = Evolv()
    let barrier = DispatchSemaphore(value: 0)

    var firstEvolv = true
    
    public func evolv() {
        DispatchQueue.global().async {
            for i in 0..<2000 {
                self.barrier.wait()
                
                let (array, loss) = self.model.forwardGroup()
                let pixels = makePixelSet(array.last!.last!)
                let image = imageFromPixels(pixels)
                DispatchQueue.main.async {
                    self.displayImage = image
                    self.runningLoss = loss
                    self.epochCount = i
                    self.objectWillChange.send()
                }
                
                self.barrier.signal()
            }
        }
    }
    
    public func evolvToggle() {
        if evolving {
            evolving = false
            barrier.wait()
        } else {
            evolving = true
            if firstEvolv {
                evolv()
                firstEvolv = false
            }
            barrier.signal()
        }
        objectWillChange.send()
    }
}
