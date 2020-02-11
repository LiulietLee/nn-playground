//
//  VisualView.swift
//  nn-playground
//
//  Created by Liuliet.Lee on 7/2/2020.
//  Copyright © 2020 Liuliet.Lee. All rights reserved.
//

import UIKit

class VisualView: UIImageView {
    
    var data = [(position: (x: Double, y: Double), label: Double)]()
    var scale = Double()
    
    public func setData(_ data: [(position: (x: Double, y: Double), label: Double)], _ scale: Double) {
        self.data = data
        self.scale = scale
        displayData()
    }
    
    func displayData() {
        let width = bounds.size.width
        let height = bounds.size.height
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
                shapeLayer.fillColor = UIColor.green.cgColor
            }
            shapeLayer.strokeColor = UIColor.black.cgColor
            shapeLayer.lineWidth = 0.3

            layer.addSublayer(shapeLayer)
        }
    }

}
