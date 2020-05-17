//
//  ViewController.swift
//  mnist-ios
//
//  Created by Liuliet.Lee on 29/1/2020.
//  Copyright © 2020 Liuliet.Lee. All rights reserved.
//

import UIKit
import MetalKit

public class PredViewController: UIViewController {
    
    var drawView: DrawView!
    var resButton: UIButton!
    var clearButton: UIButton!
    var hintLabel: UILabel!
    var predPanel: PredPanel!
    var lineCopy = [[Line]]()
    var timer: Timer!

    let reader = ImageReader()

    let model = Sequential([
        Conv(3, count: 3, padding: 1),
        Conv(3, count: 3, padding: 1),
        Conv(3, count: 3, padding: 1),
        ReLU(),
        MaxPool(2, step: 2),
        Conv(3, count: 6, padding: 1),
        Conv(3, count: 6, padding: 1),
        Conv(3, count: 6, padding: 1),
        ReLU(),
        MaxPool(2, step: 2),
        Dense(inFeatures: 6 * 7 * 7, outFeatures: 120),
        Dense(inFeatures: 120, outFeatures: 10)
    ])
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        let path = Bundle.main.path(forResource: "mnistmodel01", ofType: "nnm")!
        ModelStorage.load(model, path: path)
        
        initDrawView()
        initClearButton()
        initPredPanel()
        initHintLabel()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            if !self.drawView.lines.isEmpty, self.drawView.lines != self.lineCopy {
                self.lineCopy = self.drawView.lines
                self.check()
            }
        })

        Core.device = MTLCreateSystemDefaultDevice()
    }

    @objc func check() {
        hintLabel.isHidden = true
        let img = self.getViewImage()
        DispatchQueue.global(qos: .userInteractive).async {
            [weak self] in guard let self = self else { return }
            let res = self.model.forward(img)
            let pred = res.indexOfMax()
            let (maxv, minv) = (res[pred], res[res.indexOfMin()])
            let uniformed = (0..<res.count).map { id in
                (digit: id, pred: Double(res[id] - minv) / Double(maxv - minv))
            }
                                
            let topClass = uniformed.sorted { (pre, cur) -> Bool in
                pre.pred > cur.pred
            }[0..<5]
            
            DispatchQueue.main.async {
                [weak self] in guard let self = self else { return }
                self.predPanel.update(result: Array(topClass))
            }
        }
    }
    
    func getViewImage() -> NNArray {
        return reader.readCIImage(
            drawView.asImage().resized().asCIImage()!
        ).subArray(pos: 0, length: 784, d: [1, 1, 28, 28])
    }
    
    @objc func clear() {
        drawView.clear()
    }
}

extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

extension UIImage {
    func resized(to size: CGSize = CGSize(width: 28, height: 28)) -> UIImage {
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        return resizedImage
    }
    
    func asCIImage() -> CIImage? {
        return CIImage(image: self)
    }
}

extension PredViewController {
    func initDrawView() {
        drawView = DrawView() {
            self.check()
        }
        drawView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(drawView)
        
        NSLayoutConstraint.activate([
            drawView.topAnchor.constraint(equalTo: view.topAnchor),
            drawView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            drawView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            drawView.heightAnchor.constraint(equalTo: drawView.widthAnchor)
        ])
    }
    
    func initResButton() {
        resButton = UIButton()
        resButton.translatesAutoresizingMaskIntoConstraints = false
        resButton.setTitleColor(.white, for: .normal)
        resButton.setTitle("Tap to predict", for: .normal)
        resButton.addTarget(self, action: #selector(check), for: .touchUpInside)
        view.addSubview(resButton)
        view.bringSubviewToFront(resButton)

        NSLayoutConstraint.activate([
            resButton.bottomAnchor.constraint(equalTo: drawView.bottomAnchor),
            resButton.centerXAnchor.constraint(equalTo: drawView.centerXAnchor)
        ])
    }
    
    func initClearButton() {
        clearButton = UIButton()
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.setImage(UIImage(systemName: "trash"), for: .normal)
        clearButton.tintColor = .white
        clearButton.addTarget(self, action: #selector(clear), for: .touchUpInside)
        view.addSubview(clearButton)
        view.bringSubviewToFront(clearButton)
        
        NSLayoutConstraint.activate([
            clearButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            clearButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            clearButton.widthAnchor.constraint(equalToConstant: 35),
            clearButton.heightAnchor.constraint(equalTo: clearButton.widthAnchor)
        ])
    }
    
    func initPredPanel() {
        predPanel = PredPanel()
        predPanel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(predPanel)
        
        NSLayoutConstraint.activate([
            predPanel.topAnchor.constraint(equalTo: drawView.bottomAnchor),
            predPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            predPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            predPanel.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func initHintLabel() {
        hintLabel = UILabel()
        hintLabel.translatesAutoresizingMaskIntoConstraints = false
        hintLabel.text = "Write digits here"
        hintLabel.font = UIFont.systemFont(ofSize: 24)
        hintLabel.textColor = .gray
        view.addSubview(hintLabel)
        view.bringSubviewToFront(hintLabel)
        
        NSLayoutConstraint.activate([
            hintLabel.centerXAnchor.constraint(equalTo: drawView.centerXAnchor),
            hintLabel.centerYAnchor.constraint(equalTo: drawView.centerYAnchor)
        ])
    }
}
