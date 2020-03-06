//
//  ParameterRow.swift
//  nn-playground
//
//  Created by Liuliet.Lee on 4/3/2020.
//  Copyright © 2020 Liuliet.Lee. All rights reserved.
//

import UIKit

extension VisualizationPanel {
    class ParameterRow: UIView {
        var vm: PlaygroundViewModel!
        var layerID = 0
        var drawLayer = [[CAShapeLayer]]()

        var input: Int { vm.model.desc[layerID] }
        var output: Int { layerID < vm.model.desc.count - 1 ? vm.model.desc[layerID + 1] : 1 }

        init(vm: PlaygroundViewModel, layerID: Int) {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false

            self.vm = vm
            self.layerID = layerID

            initPath()
            updateColor()
            
            NotificationCenter.default.addObserver(self,
                selector: #selector(updateColor),
                name: Notification.Name("NewFrame"),
                object: nil
            )
            
            NotificationCenter.default.addObserver(self,
                selector: #selector(resetPath(_:)),
                name: NSNotification.Name("LayerStructChanged"),
                object: nil
            )
        }
        
        @objc func resetPath(_ notice: NSNotification) {
            guard let id = notice.userInfo?["id"] as? Int else { return }
            if id == layerID || id == layerID + 1 {
                layer.sublayers!.forEach { $0.removeFromSuperlayer() }
                drawLayer = []
                initPath()
            }
        }
        
        func initPath() {
            for i in 0..<output {
                drawLayer.append([])
                for _ in 0..<input {
                    let l = CAShapeLayer()
                    l.lineWidth = 4
                    l.fillColor = UIColor.clear.cgColor

                    drawLayer[i].append(l)
                    layer.addSublayer(l)
                }
            }
            
            for i in 0..<output {
                for j in 0..<input {
                    let to = CGPoint(x: -getMidOf(kth: i, total: output), y: 50)
                    let from = CGPoint(x: -getMidOf(kth: j, total: input), y: 0)
                    
                    let path = UIBezierPath()
                    let mid = (from.y + to.y) / 2
                    let offsetY = (mid - from.y) * 2 / 3
                    
                    path.move(to: from)
                    path.addQuadCurve(
                        to: CGPoint(x: (from.x + to.x) / 2, y: mid),
                        controlPoint: CGPoint(x: from.x, y: from.y + offsetY)
                    )
                    path.addQuadCurve(
                        to: to,
                        controlPoint: CGPoint(x: to.x, y: to.y - offsetY)
                    )

                    drawLayer[i][j].path = path.cgPath
                }
            }
        }
        
        @objc func updateColor() {
            for i in 0..<min(output, drawLayer.count) {
                for j in 0..<min(input, drawLayer[i].count) {
                    drawLayer[i][j].strokeColor = getColorBy(parameter:
                        vm.model.model.layers[layerID].param[i][j]
                    ).cgColor
                }
            }
        }
        
        func getColorBy(parameter: Double) -> UIColor {
            let elem = CGFloat(atan(parameter) * 2 / .pi)
            
            if elem > 0.0 {
                return UIColor(red: 1.0, green: (1 - elem), blue: (1 - elem), alpha: 1)
            } else {
                return UIColor(red: (1 + elem), green: (1 + elem), blue: 1.0, alpha: 1)
            }
        }
        
        func getMidOf(kth k: Int, total: Int) -> CGFloat {
            let interval = 50 + 20
            if total % 2 == 0 {
                let left = (total / 2 - 1) * interval + interval / 2
                return CGFloat(left - interval * k)
            } else {
                let left = (total / 2) * interval
                return CGFloat(left - interval * k)
            }
        }
        
        required init?(coder: NSCoder) {
            super.init(frame: .zero)
            fatalError("init(coder:) has not been implemented")
        }
    }
}
