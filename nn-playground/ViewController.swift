//
//  ViewController.swift
//  nn-playground
//
//  Created by Liuliet.Lee on 6/2/2020.
//  Copyright © 2020 Liuliet.Lee. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: VisualView!
    @IBOutlet weak var epochLabel: UILabel!
    @IBOutlet weak var lossLabel: UILabel!
    
    let model = Evolv()
    
    let barrier = DispatchSemaphore(value: 0)
    
    func evolv() {
        DispatchQueue.global().async {
            for i in 0..<2000 {
                self.barrier.wait()
                
                let (array, loss) = self.model.forwardGroup()
                let pixels = makePixelSet(array.last!.last!)
                let image = imageFromPixels(pixels)
                DispatchQueue.main.async {
                    self.imageView.image = image
                    self.lossLabel.text = "Loss: \(loss)"
                    self.epochLabel.text = "Epoch: \(i)"
                }
                
                self.barrier.signal()
            }
        }
    }
    
    var evolving = false
    
    @IBAction func startEvolving(sender: UIButton) {
        if evolving {
            evolving = false
            barrier.wait()
            sender.setTitle("Start", for: .normal)
        } else {
            evolving = true
            barrier.signal()
            sender.setTitle("Stop", for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.setData(model.data, DataGenerator.dataScale)
        
        evolv()
    }
}

