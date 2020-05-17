//
//  MaxPool+Metal.swift
//  nn
//
//  Created by Liuliet.Lee on 29/12/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import Foundation
import MetalPerformanceShaders

extension MaxPool {
    
    func forwardWithMetal(_ input: NNArray) -> NNArray {
        let pipeline = Core.pipeline(by: "maxpooling_forward");
        let queue = Core.queue()
        var info = PoolingLayerInfo(self, input: input)

        let commandBuffer = queue.makeCommandBuffer()!
        let w = min(batchSize, pipeline.threadExecutionWidth)
        let h = min(input.d[1], pipeline.maxTotalThreadsPerThreadgroup / w)
        let d = min(row * col, pipeline.maxTotalThreadsPerThreadgroup / w / h)

        let
        inputBuffer = Core.buffer(input),
        switchesBuffer = Core.buffer(switches),
        scoreBuffer = Core.buffer(score)

        #if targetEnvironment(simulator)
        Core.encode(
            commandBuffer: commandBuffer,
            pipeline: pipeline,
            buffers: Core.buffer(&info), inputBuffer, switchesBuffer, scoreBuffer,
            groupPerGrid: [batchSize, input.d[1], row * col / 49],
            thread: [1, 1, 49]
        )
        #else
        Core.encode(
            commandBuffer: commandBuffer,
            pipeline: pipeline,
            buffers: Core.buffer(&info), inputBuffer, switchesBuffer, scoreBuffer,
            grid: [batchSize, input.d[1], row * col],
            thread: [w, h, d]
        )
        #endif

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        #if targetEnvironment(simulator)
        
        Core.writeBack(from: inputBuffer, to: input)
        Core.writeBack(from: switchesBuffer, to: switches)
        Core.writeBack(from: scoreBuffer, to: score)

        #endif

        return score
    }
}

extension MaxPool {
    
    func backwardWithMetal(_ da: NNArray, _ input: NNArray, _ delta: NNArray) -> NNArray {
        let pipeline = Core.pipeline(by: "maxpooling_backward");
        let queue = Core.queue()
        var info = PoolingLayerInfo(self, input: input)
        
        let commandBuffer = queue.makeCommandBuffer()!
        let w = min(input.d[0], pipeline.threadExecutionWidth)
        let h = min(input.d[1], pipeline.maxTotalThreadsPerThreadgroup / w)
        let d = min(input.d[2] * input.d[3], pipeline.maxTotalThreadsPerThreadgroup / w / h)

        let
        switchesBuffer = Core.buffer(switches),
        deltaBuffer = Core.buffer(delta),
        daBuffer = Core.buffer(da)

        #if targetEnvironment(simulator)
        Core.encode(
            commandBuffer: commandBuffer,
            pipeline: pipeline,
            buffers: Core.buffer(&info), switchesBuffer, deltaBuffer, daBuffer,
            groupPerGrid: [input.d[0], input.d[1], input.d[2] * input.d[3] / 49],
            thread: [1, 1, 49]
        )
        #else
        Core.encode(
            commandBuffer: commandBuffer,
            pipeline: pipeline,
            buffers: Core.buffer(&info), switchesBuffer, deltaBuffer, daBuffer,
            grid: [input.d[0], input.d[1], input.d[2] * input.d[3]],
            thread: [w, h, d]
        )
        #endif
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        #if targetEnvironment(simulator)
        
        Core.writeBack(from: switchesBuffer, to: switches)
        Core.writeBack(from: deltaBuffer, to: delta)
        Core.writeBack(from: daBuffer, to: da)
        
        #endif

        return da
    }
}
