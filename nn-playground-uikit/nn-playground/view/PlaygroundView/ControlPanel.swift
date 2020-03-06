//
//  ControlPanel.swift
//  nn-playground
//
//  Created by Liuliet.Lee on 1/3/2020.
//  Copyright © 2020 Liuliet.Lee. All rights reserved.
//

import UIKit

class ControlPanel: UIView {
    
    var vm: PlaygroundViewModel!
    var restartButton: UIButton!
    var playButton: UIButton!
    var stepButton: UIButton!
    var epochCountLabel: UILabel!
    var lossValueLabel: UILabel!
    var settingButton: UIButton!
    
    init(vm: PlaygroundViewModel) {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        self.vm = vm
        
        settingButton = generateButton(withImageName: "slider.horizontal.3")
        settingButton.addTarget(self, action: #selector(settingButtonTapped), for: .touchUpInside)
        addSubview(settingButton)

        let epochLabel = generateTextLabel(text: "Epoch:")
        addSubview(epochLabel)
        
        epochCountLabel = generateValueLabel()
        addSubview(epochCountLabel)
        
        let lossLabel = generateTextLabel(text: "Loss:")
        addSubview(lossLabel)
        
        lossValueLabel = generateValueLabel()
        addSubview(lossValueLabel)

        restartButton = generateButton(withImageName: "gobackward")
        restartButton.addTarget(self, action: #selector(restartButtonTapped), for: .touchUpInside)
        addSubview(restartButton)
        
        playButton = generateButton(withImageName: "play.fill")
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        addSubview(playButton)
        
        stepButton = generateButton(withImageName: "forward.end")
        stepButton.addTarget(self, action: #selector(stepButtonTapped), for: .touchUpInside)
        addSubview(stepButton)
        
        NSLayoutConstraint.activate([
            settingButton.widthAnchor.constraint(equalToConstant: 32),
            settingButton.heightAnchor.constraint(equalTo: settingButton.widthAnchor),
            settingButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            settingButton.bottomAnchor.constraint(equalTo: epochLabel.topAnchor, constant: -60),
            
            epochLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            epochLabel.bottomAnchor.constraint(equalTo: epochCountLabel.topAnchor),
            epochCountLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            epochCountLabel.bottomAnchor.constraint(equalTo: lossLabel.topAnchor, constant: -8),
            
            lossLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            lossLabel.bottomAnchor.constraint(equalTo: lossValueLabel.topAnchor),
            lossValueLabel.bottomAnchor.constraint(equalTo: centerYAnchor),
            lossValueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            restartButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            restartButton.topAnchor.constraint(equalTo: lossValueLabel.bottomAnchor, constant: 54),
            restartButton.widthAnchor.constraint(equalToConstant: 32),
            restartButton.heightAnchor.constraint(equalTo: restartButton.widthAnchor),
            
            playButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playButton.topAnchor.constraint(equalTo: restartButton.bottomAnchor, constant: 10),
            playButton.widthAnchor.constraint(equalToConstant: 32),
            playButton.heightAnchor.constraint(equalTo: playButton.widthAnchor),
            
            stepButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            stepButton.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 10),
            stepButton.widthAnchor.constraint(equalToConstant: 32),
            stepButton.heightAnchor.constraint(equalTo: stepButton.widthAnchor),
        ])
        
        updateValue()
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(updateValue),
            name: Notification.Name("NewFrame"),
            object: nil
        )
    }
    
    func generateValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24, weight: .bold)
        return label
    }
    
    func generateTextLabel(text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 28)
        label.text = text
        return label
    }
    
    func generateButton(withImageName name: String) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.contentMode = .scaleAspectFit
        button.setBackgroundImage(UIImage(systemName: name), for: .normal)
        button.tintColor = .blue
        return button
    }
    
    @objc func updateValue() {
        epochCountLabel.text = "\(vm.epochCount)"
        lossValueLabel.text = String("\(vm.runningLoss)".prefix(7))
        playButton.setBackgroundImage(
            UIImage(systemName: vm.evolving ? "pause.fill" : "play.fill"),
            for: .normal
        )
    }
    
    @objc func restartButtonTapped() {
        vm.evolvRestart()
    }
    
    @objc func playButtonTapped() {
        vm.evolvToggle()
    }
    
    @objc func stepButtonTapped() {
        vm.evolvStop()
        vm.evolvOnce()
    }
    
    @objc func settingButtonTapped() {
        NotificationCenter.default.post(
            name: NSNotification.Name("SettingButtonTapped"),
            object: nil
        )
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
