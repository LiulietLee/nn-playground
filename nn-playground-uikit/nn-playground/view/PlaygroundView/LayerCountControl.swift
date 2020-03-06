//
//  LayerCountControl.swift
//  nn-playground
//
//  Created by Liuliet.Lee on 1/3/2020.
//  Copyright © 2020 Liuliet.Lee. All rights reserved.
//

import UIKit

class LayerCountControl: UIView {
    
    var vm: PlaygroundViewModel!

    var plusButton: UIButton!
    var minusButton: UIButton!
    var bracketLayer: BracketLayer!
    
    lazy var regularConstraint = [
        plusButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
        plusButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -30),
        plusButton.widthAnchor.constraint(equalToConstant: 30),
        plusButton.heightAnchor.constraint(equalTo: plusButton.widthAnchor),
        
        minusButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
        minusButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 30),
        minusButton.widthAnchor.constraint(equalTo: plusButton.widthAnchor),
        minusButton.heightAnchor.constraint(equalTo: plusButton.widthAnchor),
        
        bracketLayer.leadingAnchor.constraint(equalTo: plusButton.trailingAnchor, constant: 10),
        bracketLayer.topAnchor.constraint(equalTo: topAnchor),
        bracketLayer.bottomAnchor.constraint(equalTo: bottomAnchor),
        bracketLayer.trailingAnchor.constraint(equalTo: trailingAnchor)
    ]

    init(vm: PlaygroundViewModel) {
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        self.vm = vm

        plusButton = UIButton()
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.setBackgroundImage(UIImage(systemName: "plus.circle"), for: .normal)
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        plusButton.tintColor = .red
        
        minusButton = UIButton()
        minusButton.translatesAutoresizingMaskIntoConstraints = false
        minusButton.setBackgroundImage(UIImage(systemName: "minus.circle"), for: .normal)
        minusButton.addTarget(self, action: #selector(minusButtonTapped), for: .touchUpInside)
        minusButton.tintColor = .blue
        
        bracketLayer = BracketLayer(h: vm.viewHeight)
        
        addSubview(plusButton)
        addSubview(minusButton)
        addSubview(bracketLayer)
        
        NSLayoutConstraint.activate(regularConstraint)
    }
    
    @objc func plusButtonTapped() {
        vm.addLayer()
        bracketLayer.updateShape(withHeight: vm.viewHeight)
    }
    
    @objc func minusButtonTapped() {
        vm.dropLayer()
        bracketLayer.updateShape(withHeight: vm.viewHeight)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
}

extension LayerCountControl {
    class BracketLayer: UIView {
        
        var shape = CAShapeLayer()
        var height: CGFloat = 0
        
        init(h: CGFloat) {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            height = h
            addShape()
        }
        
        func newShape() -> CAShapeLayer {
            let path = UIBezierPath()
            let w: CGFloat = 50
            let h = height
            
            path.move(to: CGPoint(x: w, y: 0))
            path.addQuadCurve(
                to: CGPoint(x: w / 2, y: 60),
                controlPoint: CGPoint(x: w / 2, y: 0)
            )
            path.addLine(to: CGPoint(x: w / 2, y: h / 2 - 60))
            path.addQuadCurve(
                to: CGPoint(x: 0, y: h / 2),
                controlPoint: CGPoint(x: w / 2, y: h / 2)
            )
            path.addQuadCurve(
                to: CGPoint(x: w / 2, y: h / 2 + 60),
                controlPoint: CGPoint(x: w / 2, y: h / 2)
            )
            path.addLine(to: CGPoint(x: w / 2, y: h - 60))
            path.addQuadCurve(
                to: CGPoint(x: w, y: h),
                controlPoint: CGPoint(x: w / 2, y: h)
            )
            
            let shape = CAShapeLayer()
            shape.path = path.cgPath
            shape.strokeColor = UIColor.blue.cgColor
            shape.fillColor = UIColor.white.cgColor
            shape.lineWidth = 1.2

            return shape
        }
        
        func updateShape(withHeight h: CGFloat) {
            height = h
            let tempShape = newShape()
            layer.replaceSublayer(shape, with: tempShape)
            shape = tempShape
        }
        
        func addShape() {
            shape = newShape()
            layer.addSublayer(shape)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
