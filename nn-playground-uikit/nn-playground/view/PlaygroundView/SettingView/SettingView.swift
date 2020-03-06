//
//  SettingView.swift
//  nn-playground
//
//  Created by Liuliet.Lee on 5/3/2020.
//  Copyright © 2020 Liuliet.Lee. All rights reserved.
//

import UIKit

class SettingView: UIView {
    
    var vm: PlaygroundViewModel!
    
    init(vm: PlaygroundViewModel) {
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        self.vm = vm
        
        let panel = SettingPanel(vm: vm)
        addSubview(panel)
        
        let backButton = UIButton()
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.backgroundColor = .black
        backButton.alpha = 0.2
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        addSubview(backButton)
        
        NSLayoutConstraint.activate([
            panel.leadingAnchor.constraint(equalTo: leadingAnchor),
            panel.topAnchor.constraint(equalTo: topAnchor),
            panel.trailingAnchor.constraint(equalTo: trailingAnchor),
            panel.bottomAnchor.constraint(equalTo: centerYAnchor),
            
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            backButton.topAnchor.constraint(equalTo: centerYAnchor),
            backButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            backButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    @objc func goBack() {
        removeFromSuperview()
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
