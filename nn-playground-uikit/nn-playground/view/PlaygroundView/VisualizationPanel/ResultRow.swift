//
//  ResultRow.swift
//  nn-playground
//
//  Created by Liuliet.Lee on 4/3/2020.
//  Copyright © 2020 Liuliet.Lee. All rights reserved.
//

import UIKit

extension VisualizationPanel {
    class ResultRow: UIView {
        var resultImage = [UIImageView]()
        var vm: PlaygroundViewModel!
        var layerID = 0
        var plusButton: UIButton!
        var minusButton: UIButton!
        
        func constraint() -> [NSLayoutConstraint] {
            var cons = [resultImage[0].leadingAnchor.constraint(equalTo: leadingAnchor, constant: 48)]
            
            cons.append(contentsOf: (0..<resultImage.count - 1).map { i in
                resultImage[i].trailingAnchor.constraint(
                    equalTo: resultImage[i + 1].leadingAnchor, constant: -20
                )
            })
                
            cons.append(contentsOf: resultImage.flatMap { image in [
                image.topAnchor.constraint(equalTo: topAnchor),
                image.widthAnchor.constraint(equalToConstant: 50),
                image.heightAnchor.constraint(equalTo: image.widthAnchor)
            ]})
            
            return cons
        }
        
        init(vm: PlaygroundViewModel, layerID: Int) {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            
            self.vm = vm
            self.layerID = layerID
            addImage()
            
            if layerID > 0 {
                addButton()
            }
            
            NotificationCenter.default.addObserver(self,
                selector: #selector(frameUpdate),
                name: Notification.Name("NewFrame"),
                object: nil
            )
            
            NotificationCenter.default.addObserver(self,
                selector: #selector(resetImages(_:)),
                name: NSNotification.Name("LayerStructChanged"),
                object: nil
            )
        }
        
        @objc func resetImages(_ notification: Notification) {
            guard let id = notification.userInfo?["id"] as? Int else { return }
            if id == layerID {
                subviews.forEach { $0.removeFromSuperview() }
                resultImage = []
                plusButton = nil
                minusButton = nil
                addImage()
                
                if layerID > 0 {
                    addButton()
                }
            }
        }
        
        @objc func frameUpdate() {
            for i in 0..<min(resultImage.count, vm.model.desc[layerID]) {
                resultImage[i].image = vm.visualImages[layerID][i]
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func addImage() {
            for i in 0..<vm.model.desc[layerID] {
                let imageView = UIImageView()
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.image = vm.visualImages[layerID][i]
                imageView.layer.masksToBounds = true
                imageView.layer.cornerRadius = 8
                
                imageView.layer.borderWidth = 0.2
                imageView.layer.borderColor = UIColor.gray.cgColor

                addSubview(imageView)
                resultImage.append(imageView)
            }
            
            NSLayoutConstraint.activate(constraint())
        }
        
        func addButton() {
            plusButton = UIButton()
            plusButton.translatesAutoresizingMaskIntoConstraints = false
            plusButton.setBackgroundImage(UIImage(systemName: "plus.circle"), for: .normal)
            plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
            plusButton.tintColor = .red
            addSubview(plusButton)
            
            minusButton = UIButton()
            minusButton.translatesAutoresizingMaskIntoConstraints = false
            minusButton.setBackgroundImage(UIImage(systemName: "minus.circle"), for: .normal)
            minusButton.addTarget(self, action: #selector(minusButtonTapped), for: .touchUpInside)
            minusButton.tintColor = .blue
            addSubview(minusButton)
            
            NSLayoutConstraint.activate([
                plusButton.widthAnchor.constraint(equalToConstant: 30),
                plusButton.heightAnchor.constraint(equalTo: plusButton.widthAnchor),
                plusButton.centerYAnchor.constraint(equalTo: centerYAnchor),
                plusButton.leadingAnchor.constraint(equalTo: resultImage.last!.trailingAnchor, constant: 18),
                
                minusButton.widthAnchor.constraint(equalTo: plusButton.widthAnchor),
                minusButton.heightAnchor.constraint(equalTo: plusButton.widthAnchor),
                minusButton.centerYAnchor.constraint(equalTo: centerYAnchor),
                minusButton.trailingAnchor.constraint(equalTo: resultImage.first!.leadingAnchor, constant: -18),
            ])
        }
        
        @objc func plusButtonTapped() {
            vm.addNeuron(at: layerID)
        }
        
        @objc func minusButtonTapped() {
            vm.dropNeuron(at: layerID)
        }
    }
}
