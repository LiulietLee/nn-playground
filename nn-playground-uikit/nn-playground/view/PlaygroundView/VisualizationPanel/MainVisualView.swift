//
//  MainVisualView.swift
//  nn-playground
//
//  Created by Liuliet.Lee on 4/3/2020.
//  Copyright © 2020 Liuliet.Lee. All rights reserved.
//

import UIKit

extension VisualizationPanel {
    class MainVisualView: UIImageView {
        var data: [Sample] { vm.model.data }
        var scale = 0.0
        var vm: PlaygroundViewModel!
        
        func displayData() {
            let width: CGFloat = 180
            let height: CGFloat = 180
            
            for elem in data {
                let x = width * (CGFloat(elem.position.x / scale) + 1.0) / 2
                let y = height * (CGFloat(elem.position.y / scale) + 1.0) / 2
                let path = UIBezierPath(
                    arcCenter: CGPoint(x: x, y: y),
                    radius: 2.0,
                    startAngle: 0,
                    endAngle: 2 * .pi,
                    clockwise: true
                )
                
                let shapeLayer = CAShapeLayer()
                shapeLayer.path = path.cgPath

                if elem.label > 0 {
                    shapeLayer.fillColor = UIColor.red.cgColor
                } else {
                    shapeLayer.fillColor = UIColor.white.cgColor
                }
                shapeLayer.strokeColor = UIColor.black.cgColor
                shapeLayer.lineWidth = 0.3

                layer.addSublayer(shapeLayer)
            }
        }
        
        init(vm: PlaygroundViewModel) {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            
            self.vm = vm
            scale = DataGenerator.dataScale
            
            displayData()
            image = vm.mainImage
            
            layer.masksToBounds = true
            layer.cornerRadius = 8
            
            layer.borderWidth = 0.2
            layer.borderColor = UIColor.gray.cgColor
            
            NotificationCenter.default.addObserver(self,
                selector: #selector(frameUpdate),
                name: Notification.Name("NewFrame"),
                object: nil
            )
            
            NotificationCenter.default.addObserver(self,
                selector: #selector(sampleUpdate),
                name: Notification.Name("SampleUpdated"),
                object: nil
            )
        }
        
        @objc func frameUpdate() {
            image = vm.mainImage
        }
        
        @objc func sampleUpdate() {
            layer.sublayers!.forEach { $0.removeFromSuperlayer() }
            displayData()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
