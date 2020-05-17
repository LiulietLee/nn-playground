//
//  PredPanel.swift
//  mnist-ios
//
//  Created by Liuliet.Lee on 14/5/2020.
//  Copyright © 2020 Liuliet.Lee. All rights reserved.
//

import UIKit

class PredPanel: UIView {

    var rows = [PredRow]()

    init() {
        super.init(frame: .zero)
        initRows()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(result: [(digit: Int, pred: Double)]) {
        for (i, res) in result.enumerated() {
            rows[i].update(digit: res.digit, progress: res.pred, color: i == 0 ? .red : .blue)
        }
    }
    
    func initRows() {
        for i in 0..<5 {
            let row = PredRow()
            row.translatesAutoresizingMaskIntoConstraints = false
            addSubview(row)
            
            NSLayoutConstraint.activate([
                row.leadingAnchor.constraint(equalTo: leadingAnchor),
                row.trailingAnchor.constraint(equalTo: trailingAnchor),
                row.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.2)
            ])
            
            if i == 0 {
                NSLayoutConstraint.activate([
                    row.topAnchor.constraint(equalTo: topAnchor)
                ])
            } else {
                NSLayoutConstraint.activate([
                    row.topAnchor.constraint(equalTo: rows[i - 1].bottomAnchor)
                ])
            }
            
            rows.append(row)
        }
    }
}
