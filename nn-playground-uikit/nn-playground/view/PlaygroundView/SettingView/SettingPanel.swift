//
//  SettingPanel.swift
//  nn-playground
//
//  Created by Liuliet.Lee on 6/3/2020.
//  Copyright © 2020 Liuliet.Lee. All rights reserved.
//

import UIKit

extension SettingView {
    class SettingPanel: UIView {
        var vm: PlaygroundViewModel!
        
        var imageLabel = [UILabel]()
        var imageButton = [UIButton]()
        
        var learningRateValueLabel: UILabel!
        var noiseValueLabel: UILabel!
        var batchSizeValueLabel: UILabel!
        
        var learningRateSlider: UISlider!
        var noiseSlider: UISlider!
        var batchSizeSlider: UISlider!
        
        let imageDisplayName = ["𝒙", "𝒚", "𝒙\u{00b2}", "𝒚\u{00b2}", "𝒙𝒚", "sin𝒙", "sin𝒚"]
        let imageSystemName = ["x", "y", "x2", "y2", "xy", "sinx", "siny"]

        init(vm: PlaygroundViewModel) {
            super.init(frame: .zero)
            
            translatesAutoresizingMaskIntoConstraints = false
            backgroundColor = .white
            self.vm = vm
            
            for i in 0..<7 {
                imageLabel.append(newNoteLabel(withText: imageDisplayName[i]))
                addSubview(imageLabel.last!)
                
                imageButton.append(newImageButton(withID: i))
                addSubview(imageButton.last!)
            }
            
            NSLayoutConstraint.activate((0..<7).flatMap {
                constraintForImageLabel(withID: $0) + constraintForImageButton(withID: $0)
            })
            
            let learningRateLabel = newSliderLabel(withText: "Learning Rate: ")
            learningRateValueLabel = newSliderLabel(withText: String("\(vm.learningRateScaler * 0.0001)".prefix(6)))
            learningRateSlider = newSlider(
                v: Float(vm.learningRateScaler),
                minv: 1, maxv: 2000,
                action: #selector(learningRateChanged(_:))
            )

            let batchSizeLabel = newSliderLabel(withText: "Batch Size: ")
            batchSizeValueLabel = newSliderLabel(withText: "\(Int(vm.batchSize))")
            batchSizeSlider = newSlider(
                v: Float(vm.batchSize),
                minv: 1, maxv: 50,
                action: #selector(batchSizeChanged(_:))
            )

            let noiseLabel = newSliderLabel(withText: "Noise: ")
            noiseValueLabel = newSliderLabel(withText: "\(Int(vm.dataNoise * 100))%")
            noiseSlider = newSlider(
                v: Float(vm.dataNoise),
                minv: 0, maxv: 1,
                action: #selector(noiseChanged(_:))
            )
            
            placeSliderGroup(
                label: learningRateLabel,
                value: learningRateValueLabel,
                slider: learningRateSlider
            )
            placeSliderGroup(
                label: batchSizeLabel,
                value: batchSizeValueLabel,
                slider: batchSizeSlider
            )
            placeSliderGroup(
                label: noiseLabel,
                value: noiseValueLabel,
                slider: noiseSlider
            )
            
            NSLayoutConstraint.activate([
                batchSizeSlider.centerYAnchor.constraint(equalTo: centerYAnchor),
                batchSizeSlider.topAnchor.constraint(equalTo: learningRateSlider.bottomAnchor, constant: 80),
                batchSizeSlider.bottomAnchor.constraint(equalTo: noiseSlider.topAnchor, constant: -80)
            ])
        }
        
        func placeSliderGroup(label: UILabel, value: UILabel, slider: UISlider) {
            addSubview(label)
            addSubview(value)
            addSubview(slider)
            
            NSLayoutConstraint.activate([
                label.trailingAnchor.constraint(equalTo: value.leadingAnchor, constant: -10),
                label.centerYAnchor.constraint(equalTo: value.centerYAnchor),
                label.trailingAnchor.constraint(equalTo: slider.centerXAnchor),
                label.bottomAnchor.constraint(equalTo: slider.topAnchor, constant: -8),
                
                slider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
                slider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 150)
            ])
        }
        
        func newSliderLabel(withText text: String = "") -> UILabel {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = .systemFont(ofSize: 28)
            label.text = text
            return label
        }
        
        func newSlider(v: Float, minv: Float, maxv: Float, action: Selector) -> UISlider {
            let slider = UISlider()
            slider.translatesAutoresizingMaskIntoConstraints = false
            slider.minimumValue = minv
            slider.maximumValue = maxv
            slider.addTarget(self, action: action, for: .valueChanged)
            slider.setValue(v, animated: true)
            return slider
        }
        
        func newNoteLabel(withText text: String) -> UILabel {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = .systemFont(ofSize: 24)
            label.text = text
            return label
        }
        
        func newImageButton(withID id: Int) -> UIButton {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tag = id + 114514
            button.setBackgroundImage(UIImage(named: imageSystemName[id]), for: .normal)
            button.alpha = Transform.transform[id].isEnable ? 1.0 : 0.2
            button.addTarget(self, action: #selector(imageButtonTapped(_:)), for: .touchUpInside)
            button.layer.masksToBounds = true
            button.layer.cornerRadius = 8
            return button
        }
        
        func constraintForImageButton(withID i: Int) -> [NSLayoutConstraint] {
            var cons = [
                imageButton[i].widthAnchor.constraint(equalToConstant: 40),
                imageButton[i].heightAnchor.constraint(equalTo: imageButton[i].widthAnchor),
                imageButton[i].leadingAnchor.constraint(equalTo: leadingAnchor, constant: 80)
            ]
            
            if i != 0 {
                cons.append(
                    imageButton[i].topAnchor.constraint(
                        equalTo: imageButton[i - 1].bottomAnchor,
                        constant: 10
                    )
                )
            }
            
            if i == 3 {
                cons.append(
                    imageButton[i].centerYAnchor.constraint(equalTo: centerYAnchor)
                )
            }
            
            return cons
        }
        
        func constraintForImageLabel(withID i: Int) -> [NSLayoutConstraint] {[
            imageLabel[i].centerYAnchor.constraint(equalTo: imageButton[i].centerYAnchor),
            imageLabel[i].trailingAnchor.constraint(equalTo: imageButton[i].leadingAnchor, constant: -16)
        ]}
        
        @objc func imageButtonTapped(_ sender: UIButton) {
            let id = sender.tag - 114514
            vm.toggleInput(id: id)
            sender.alpha = Transform.transform[id].isEnable ? 1.0 : 0.2
        }
        
        @objc func learningRateChanged(_ sender: UISlider) {
            vm.learningRateScaler = Double(sender.value)
            learningRateValueLabel.text = String("\(vm.learningRateScaler * 0.0001)".prefix(6))
        }
        
        @objc func batchSizeChanged(_ sender: UISlider) {
            vm.batchSize = Double(Int(sender.value))
            batchSizeValueLabel.text = "\(Int(vm.batchSize))"
        }
        
        @objc func noiseChanged(_ sender: UISlider) {
            vm.dataNoise = Double(sender.value)
            noiseValueLabel.text = "\(Int(vm.dataNoise * 100))%"
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
