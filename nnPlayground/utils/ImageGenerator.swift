//
//  ImageGenerator.swift
//  nn-playground
//
//  Created by Liuliet.Lee on 6/2/2020.
//  Copyright © 2020 Liuliet.Lee. All rights reserved.
//

import UIKit

public struct Pixel {
    var r: UInt8
    var g: UInt8
    var b: UInt8
    var a: UInt8
    
    public init(red: UInt8 = 0, green: UInt8 = 0, blue: UInt8 = 0) {
        r = red
        g = green
        b = blue
        a = 255
    }
    
    public init(red: Double, green: Double, blue: Double) {
        r = UInt8(red * 255.0)
        g = UInt8(green * 255.0)
        b = UInt8(blue * 255.0)
        a = 255
    }
    
    public init(red: Int, green: Int, blue: Int) {
        r = UInt8(red)
        g = UInt8(green)
        b = UInt8(blue)
        a = 255
    }
}

public func makePixelSet(_ width: Int, _ height: Int) -> [[Pixel]] {
    let pixel = Pixel(red: 0, green: 0, blue: 0)
    let pixels = [[Pixel]](repeating: [Pixel](repeating: pixel, count: width), count: height)
    return pixels
}

public func makePixelSet(_ array: [[Double]]) -> [[Pixel]] {
    let height = array.count, width = array[0].count
    var pixels = [[Pixel]](repeating: [Pixel](repeating: Pixel(), count: width), count: height)
        
    for i in 0..<height {
        for j in 0..<width {
            let elem = atan(array[i][j]) * 2 / .pi
            
            if elem > 0.0 {
                pixels[i][j] = Pixel(red: 1.0, green: (1 - elem), blue: (1 - elem))
            } else {
                pixels[i][j] = Pixel(red: (1 + elem), green: (1 + elem), blue: 1.0)
            }
        }
    }
    
    return pixels
}

public func imageFromPixels(_ pixels: [[Pixel]]) -> UIImage {
    let height = pixels.count
    let width = pixels[0].count
    
    let bitsPerComponent = 8
    let bitsPerPixel = 32
    let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

    guard let providerRef = CGDataProvider(data: NSData(
        bytes: pixels.flatMap { $0 },
        length: width * height * MemoryLayout<Pixel>.stride
    )) else {
        fatalError("cannot create provider ref")
    }
    
    let image = CGImage(
        width: width,
        height: height,
        bitsPerComponent: bitsPerComponent,
        bitsPerPixel: bitsPerPixel,
        bytesPerRow: width * MemoryLayout<Pixel>.stride,
        space: rgbColorSpace,
        bitmapInfo: bitmapInfo,
        provider: providerRef,
        decode: nil,
        shouldInterpolate: true,
        intent: .defaultIntent
    )
    
    return UIImage(cgImage: image!)
}
