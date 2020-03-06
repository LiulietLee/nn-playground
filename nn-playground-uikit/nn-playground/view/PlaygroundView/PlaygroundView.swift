//
//  PlaygroundView.swift
//  nn-playground
//
//  Created by Liuliet.Lee on 29/2/2020.
//  Copyright © 2020 Liuliet.Lee. All rights reserved.
//

import UIKit

public class PlaygroundView: UIView {
    
    var vm = PlaygroundViewModel()
    var layerCountControl: LayerCountControl!
    var visualizationPanel: VisualizationPanel!
    var controlPanel: ControlPanel!
    var settingView: SettingView!
    
    lazy var regularConstraints = [
        layerCountControl.leadingAnchor.constraint(equalTo: leadingAnchor),
        layerCountControl.widthAnchor.constraint(equalToConstant: 80),
        layerCountControl.heightAnchor.constraint(equalTo: visualizationPanel.heightAnchor),
        layerCountControl.centerYAnchor.constraint(equalTo: centerYAnchor),
        layerCountControl.trailingAnchor.constraint(equalTo: visualizationPanel.leadingAnchor),
        
        visualizationPanel.centerYAnchor.constraint(equalTo: centerYAnchor),
        visualizationPanel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8, constant: -80),
        visualizationPanel.trailingAnchor.constraint(equalTo: controlPanel.leadingAnchor),
        
        controlPanel.centerYAnchor.constraint(equalTo: centerYAnchor),
        controlPanel.trailingAnchor.constraint(equalTo: trailingAnchor),
        controlPanel.heightAnchor.constraint(equalTo: visualizationPanel.heightAnchor),
        controlPanel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2)
    ]
    
    var visualizationPanelHeight: NSLayoutConstraint!
        
    func getVisualizationPanelHeight() -> NSLayoutConstraint {
        visualizationPanelHeight = visualizationPanel.heightAnchor.constraint(
            equalToConstant: vm.viewHeight
        )
        return visualizationPanelHeight
    }

    public init() {
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        layerCountControl = LayerCountControl(vm: vm)
        visualizationPanel = VisualizationPanel(vm: vm)
        controlPanel = ControlPanel(vm: vm)

        addSubview(layerCountControl)
        addSubview(visualizationPanel)
        addSubview(controlPanel)

        NSLayoutConstraint.activate(regularConstraints)
        NSLayoutConstraint.activate([getVisualizationPanelHeight()])
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(resizeView),
            name: Notification.Name("ModelStructChanged"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(showSetting),
            name: Notification.Name("SettingButtonTapped"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(hideSetting),
            name: Notification.Name("HideSettingButtonTapped"),
            object: nil
        )
    }
    
    @objc func resizeView() {
        NSLayoutConstraint.deactivate([visualizationPanelHeight])
        NSLayoutConstraint.activate([getVisualizationPanelHeight()])
    }
    
    @objc func showSetting() {
        vm.evolvStop()
        settingView = SettingView(vm: vm)
        addSubview(settingView)
        bringSubviewToFront(settingView)
        NSLayoutConstraint.activate(settingView.constraintsForAnchoringTo(boundsOf: self))
    }
    
    @objc func hideSetting() {
        settingView.removeFromSuperview()
        settingView = nil
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

extension UIView {
    func constraintsForAnchoringTo(boundsOf view: UIView) -> [NSLayoutConstraint] {
        return [
            topAnchor.constraint(equalTo: view.topAnchor),
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor)
        ]
    }
}
