//
//  ViewController.swift
//  nn-playground
//
//  Created by Liuliet.Lee on 29/2/2020.
//  Copyright © 2020 Liuliet.Lee. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        let playgroundView = PlaygroundView()
        view.addSubview(playgroundView)
        let bounds = playgroundView.constraintsForAnchoringTo(boundsOf: view)
        NSLayoutConstraint.activate(bounds)
    }
}
