//
//  Transform.swift
//  nn-playground
//
//  Created by Liuliet.Lee on 10/2/2020.
//  Copyright © 2020 Liuliet.Lee. All rights reserved.
//

import Foundation

public class Transform {
    
    public typealias Method = ((_ x: Double, _ y: Double) -> Double)
    
    public static var transform: [(method: Method, isEnable: Bool)] = [
        ({ (x, y) in return x }, true),
        ({ (x, y) in return y }, true),
        ({ (x, y) in return x * x }, false),
        ({ (x, y) in return y * y }, false),
        ({ (x, y) in return x * y }, false),
        ({ (x, y) in return sin(x) }, false),
        ({ (x, y) in return sin(y) }, false)
    ] {
        didSet {
            enabledTransform = transform.filter({ $0.isEnable }).map({ $0.method })
        }
    }
    
    public static var enabledTransform = [
        transform[0].method,
        transform[1].method
    ]
    
    public static func toggle(_ i: Int) {
        transform[i].isEnable = !transform[i].isEnable
    }
    
    public static func transform(_ p: (x: Double, y: Double)) -> [[Double]] {
        return [enabledTransform.map({ $0(p.x, p.y) })]
    }
}
