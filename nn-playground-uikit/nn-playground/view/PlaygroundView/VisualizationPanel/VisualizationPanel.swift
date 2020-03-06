//
//  VisualizationPanel.swift
//  nn-playground
//
//  Created by Liuliet.Lee on 1/3/2020.
//  Copyright © 2020 Liuliet.Lee. All rights reserved.
//

import UIKit

class VisualizationPanel: UIView {

    var vm: PlaygroundViewModel!
    var resultRowList = [ResultRow]()
    var parameterRowList = [ParameterRow]()
    var mainVisualView: MainVisualView!
    
    func resultRowConstraint(at i: Int) -> [NSLayoutConstraint] {
        var cons = [
            resultRowList[i].bottomAnchor.constraint(equalTo: parameterRowList[i].topAnchor),
            resultRowList[i].heightAnchor.constraint(equalToConstant: 50),
            resultRowList[i].widthAnchor.constraint(equalToConstant: vm.rowWidth(i)),
            resultRowList[i].centerXAnchor.constraint(equalTo: centerXAnchor),
        ]
        
        if i == 0 {
            cons.append(resultRowList[i].topAnchor.constraint(equalTo: topAnchor))
        } else {
            cons.append(
                resultRowList[i].topAnchor.constraint(equalTo: parameterRowList[i - 1].bottomAnchor)
            )
        }
        
        return cons
    }
    
    func parameterRowConstraint(at i: Int) -> [NSLayoutConstraint] {
        var cons = [
            parameterRowList[i].leadingAnchor.constraint(equalTo: centerXAnchor),
            parameterRowList[i].trailingAnchor.constraint(equalTo: trailingAnchor),
            parameterRowList[i].heightAnchor.constraint(equalToConstant: 50),
        ]
        
        if i < parameterRowList.count - 1 {
            cons.append(
                parameterRowList[i].bottomAnchor.constraint(equalTo: resultRowList[i + 1].topAnchor)
            )
        }
        
        return cons
    }
    
    func rowConstraint(_ i: Int) -> [NSLayoutConstraint] {
        parameterRowConstraint(at: i) + resultRowConstraint(at: i)
    }
    
    func mainVisualViewConstraint() -> [NSLayoutConstraint] {[
        mainVisualView.topAnchor.constraint(equalTo: parameterRowList.last!.bottomAnchor),
        mainVisualView.centerXAnchor.constraint(equalTo: centerXAnchor),
        mainVisualView.widthAnchor.constraint(equalToConstant: 180),
        mainVisualView.heightAnchor.constraint(equalTo: mainVisualView.widthAnchor)
    ]}
    
    init(vm: PlaygroundViewModel) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.vm = vm
        
        buildView()
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(rebuildView),
            name: Notification.Name("ModelStructChanged"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(resizeRow(_:)),
            name: NSNotification.Name("LayerStructChanged"),
            object: nil
        )
    }
    
    func buildView() {
        for i in 0..<vm.model.desc.count {
            let resultRow = ResultRow(vm: vm, layerID: i)
            let paramRow = ParameterRow(vm: vm, layerID: i)
            
            resultRowList.append(resultRow)
            parameterRowList.append(paramRow)
            
            addSubview(resultRow)
            addSubview(paramRow)
        }
        
        mainVisualView = MainVisualView(vm: vm)
        addSubview(mainVisualView)
        NSLayoutConstraint.activate(
            mainVisualViewConstraint() + (0..<resultRowList.count).flatMap {
                rowConstraint($0)
            }
        )
    }
    
    @objc func rebuildView() {
        subviews.forEach { $0.removeFromSuperview() }
        resultRowList = []
        parameterRowList = []
        mainVisualView = nil
        buildView()
    }
    
    @objc func resizeRow(_ notification: Notification) {
        guard let id = notification.userInfo?["id"] as? Int else { return }
        for con in resultRowList[id].constraints {
            if con.firstItem is ResultRow, con.firstAttribute == .width {
                con.constant = vm.rowWidth(id)
            }
        }
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
