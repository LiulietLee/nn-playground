//
//  PredRow.swift
//  mnist-ios
//
//  Created by Liuliet.Lee on 14/5/2020.
//  Copyright © 2020 Liuliet.Lee. All rights reserved.
//

import UIKit

class PredRow: UIView {

    var digitLabel: UILabel!
    var progressBar: UILabel!
    var progress: Double = 0

    init() {
        super.init(frame: .zero)
        initDigitLabel()
        initProgressBar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(digit: Int, progress: Double, color: UIColor) {
        digitLabel.text = String(digit)
        digitLabel.tintColor = color
        progressBar.backgroundColor = color
        NSLayoutConstraint.deactivate([progressBar.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8 * CGFloat(self.progress))])
        NSLayoutConstraint.activate([progressBar.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8 * CGFloat(progress))])
        self.progress = progress
        setNeedsDisplay()
    }
    
    func initDigitLabel() {
        digitLabel = UILabel()
        digitLabel.translatesAutoresizingMaskIntoConstraints = false
        digitLabel.font = UIFont.systemFont(ofSize: 24)
        digitLabel.tintColor = .blue
        addSubview(digitLabel)
        
        NSLayoutConstraint.activate([
            digitLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            digitLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func initProgressBar() {
        progressBar = UILabel()
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.backgroundColor = .blue
        addSubview(progressBar)
        
        NSLayoutConstraint.activate([
            progressBar.leadingAnchor.constraint(equalTo: digitLabel.trailingAnchor, constant: 8),
            progressBar.centerYAnchor.constraint(equalTo: centerYAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 20),
            progressBar.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8 * CGFloat(progress))
        ])
    }
}

