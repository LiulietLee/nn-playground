//
//  Core.swift
//  nn
//
//  Created by Liuliet.Lee on 22/12/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import Foundation
import MetalPerformanceShaders

/**
 Metal Core.
 */
public class Core {
    
    public static var device: MTLDevice? = nil {
        didSet {
            if device != nil {
                let path = Bundle.main.path(forResource: "all_in_one", ofType: "metal")
                let input = try! String(contentsOfFile: path!, encoding: .utf8)
                library = try! device!.makeLibrary(source: input, options: nil)
            }
        }
    }
    
    static var library: MTLLibrary!
    
    static var functionMap = [String: MTLFunction]()
    
    static let mutex1 = DispatchSemaphore(value: 1)
    
    static func function(_ name: String) -> MTLFunction {
        mutex1.wait()
        defer {
            mutex1.signal()
        }
        if let function = functionMap[name] {
            return function
        } else {
            let function = library.makeFunction(name: name)!
            functionMap[name] = function
            return function
        }
    }
    
    static let mutex2 = DispatchSemaphore(value: 1)

    static func pipeline(by functionName: String) -> MTLComputePipelineState {
        mutex2.wait()
        defer {
            mutex2.signal()
        }
        return try! device!.makeComputePipelineState(function: function(functionName))
    }
    
    static let mutex3 = DispatchSemaphore(value: 1)

    static func queue() -> MTLCommandQueue {
        mutex3.wait()
        defer {
            mutex3.signal()
        }
        return device!.makeCommandQueue()!
    }
    
    @discardableResult
    static func encode(
        commandBuffer: MTLCommandBuffer,
        pipeline: MTLComputePipelineState,
        buffers: MTLBuffer...,
        grid: [Int],
        thread: [Int]
    ) -> MTLComputeCommandEncoder {
        let encoder = commandBuffer.makeComputeCommandEncoder()!
        encoder.setComputePipelineState(pipeline)
        for i in 0..<buffers.count {
            encoder.setBuffer(buffers[i], offset: 0, index: i)
        }
        let gridSize = MTLSizeMake(grid[0], grid[1], grid[2])
        let threadSize = MTLSizeMake(thread[0], thread[1], thread[2])
        encoder.dispatchThreads(gridSize, threadsPerThreadgroup: threadSize)
        encoder.endEncoding()

        return encoder
    }
    
    @discardableResult
    static func encode(
        commandBuffer: MTLCommandBuffer,
        pipeline: MTLComputePipelineState,
        buffers: MTLBuffer...,
        groupPerGrid: [Int],
        thread: [Int]
    ) -> MTLComputeCommandEncoder {
        let encoder = commandBuffer.makeComputeCommandEncoder()!
        encoder.setComputePipelineState(pipeline)
        for i in 0..<buffers.count {
            encoder.setBuffer(buffers[i], offset: 0, index: i)
        }
        let gridSize = MTLSizeMake(groupPerGrid[0], groupPerGrid[1], groupPerGrid[2])
        let threadSize = MTLSizeMake(thread[0], thread[1], thread[2])
        encoder.dispatchThreadgroups(gridSize, threadsPerThreadgroup: threadSize)
        encoder.endEncoding()

        return encoder
    }
    
    static func buffer<T>(_ data: inout T, count: Int = 1) -> MTLBuffer {
        return device!.makeBuffer(
            bytes: &data,
            length: MemoryLayout<T>.stride * count,
            options: .storageModeShared
        )!
    }
    
    static func buffer<T>(_ vec: LLVector<T>) -> MTLBuffer {
        #if targetEnvironment(simulator)
        return device!.makeBuffer(
            bytes: vec.pointer,
            length: vec.byteSize,
            options: []
        )!
        #else
        return device!.makeBuffer(
            bytesNoCopy: vec.pointer,
            length: vec.byteSize,
            options: .storageModeShared,
            deallocator: nil
        )!
        #endif
    }
    
    static func buffer(_ arr: NNArray) -> MTLBuffer {
        return buffer(arr.data)
    }
    
    static func writeBack(from buffer: MTLBuffer, to arr: NNArray) {
        memcpy(arr.data.pointer, buffer.contents(), arr.data.byteSize)
    }
    
    static func writeBack<T>(from buffer: MTLBuffer, to vec: LLVector<T>) {
        memcpy(vec.pointer, buffer.contents(), vec.byteSize)
    }
    
//    static func startCapture() {
//        let captureManager = MTLCaptureManager.shared()
//        let captureDescriptor = MTLCaptureDescriptor()
//        captureDescriptor.captureObject = Core.device
//        do {
//            try captureManager.startCapture(with: captureDescriptor)
//        } catch {
//            fatalError("error when trying to capture: \(error)")
//        }
//    }
//
//    static func stopCapture() {
//        let captureManager = MTLCaptureManager.shared()
//        captureManager.stopCapture()
//    }
}
