//
//  Dense+Metal.swift
//  nn
//
//  Created by Liuliet.Lee on 22/12/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import Foundation
import MetalPerformanceShaders

extension Dense {
    
    private func matrixMul(matrix: NNArray, input: NNArray, batch: Int) {
        let pipeline = Core.pipeline(by: "dense_matrix_mul");
        let queue = Core.queue()
        
        let commandBuffer = queue.makeCommandBuffer()!
        let w = min(batch, pipeline.threadExecutionWidth)
        let h = min(outFeatures, pipeline.maxTotalThreadsPerThreadgroup / w)
        let d = min(inFeatures, pipeline.maxTotalThreadsPerThreadgroup / w / h)

        let
        inputBuffer = Core.buffer(input),
        matrixBuffer = Core.buffer(matrix)

        #if targetEnvironment(simulator)
        let thread = inFeatures % 49 == 0 ? [1, 10, 49] : [1, 10, 10]
        Core.encode(
            commandBuffer: commandBuffer,
            pipeline: pipeline,
            buffers: inputBuffer, Core.buffer(&outFeatures),  Core.buffer(&inFeatures), matrixBuffer,
            groupPerGrid: [batch, outFeatures / thread[1], inFeatures / thread[2]],
            thread: thread
        )
        #else
        Core.encode(
            commandBuffer: commandBuffer,
            pipeline: pipeline,
            buffers: inputBuffer, Core.buffer(&outFeatures),  Core.buffer(&inFeatures), matrixBuffer,
            grid: [batch, outFeatures, inFeatures],
            thread: [w, h, d]
        )
        #endif
                
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        #if targetEnvironment(simulator)
        
        Core.writeBack(from: inputBuffer, to: input)
        Core.writeBack(from: matrixBuffer, to: matrix)

        #endif
    }
    
    private func matrixSum(matrix: NNArray, batch: Int, inter: NNArray, output: NNArray) {
        let pipeline = Core.pipeline(by: "dense_matrix_sum");
        let queue = Core.queue()
        
        let commandBuffer = queue.makeCommandBuffer()!
        let w = min(batch, pipeline.threadExecutionWidth)
        let h = min(outFeatures, pipeline.maxTotalThreadsPerThreadgroup / w)
        
        let
        matrixBuffer = Core.buffer(matrix),
        biasBuffer = Core.buffer(bias),
        outputBuffer = Core.buffer(output),
        interBuffer = Core.buffer(inter)

        #if targetEnvironment(simulator)
        Core.encode(
            commandBuffer: commandBuffer,
            pipeline: pipeline,
            buffers: matrixBuffer, Core.buffer(&inFeatures), Core.buffer(&outFeatures), biasBuffer, Core.buffer(&relu), outputBuffer, interBuffer,
            groupPerGrid: [batch, outFeatures / 10, 1],
            thread: [1, 10, 1]
        )
        #else
        Core.encode(
            commandBuffer: commandBuffer,
            pipeline: pipeline,
            buffers: matrixBuffer, Core.buffer(&inFeatures), Core.buffer(&outFeatures), biasBuffer, Core.buffer(&relu), outputBuffer, interBuffer,
            grid: [batch, outFeatures, 1],
            thread: [w, h, 1]
        )
        #endif
                
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        #if targetEnvironment(simulator)
        
        Core.writeBack(from: matrixBuffer, to: matrix)
        Core.writeBack(from: biasBuffer, to: bias)
        Core.writeBack(from: outputBuffer, to: output)
        Core.writeBack(from: interBuffer, to: inter)

        #endif
    }
    
    func forwardWithMetal(_ batch: Int, _ input: NNArray, _ inter: NNArray, _ output: NNArray) {
        let cp = NNArray(batch, outFeatures, inFeatures)
        for i in 0..<batch {
            memcpy(
                cp.subArray(at: i).data.pointer,
                param.data.pointer,
                MemoryLayout<Float>.stride * outFeatures * inFeatures
            )
        }
        matrixMul(matrix: cp, input: input, batch: batch)
        matrixSum(matrix: cp, batch: batch, inter: inter, output: output)
    }
}

extension Dense {
    
    private func backward1(_ da: NNArray, _ delta: NNArray) {
        // let row = outFeatures, col = inFeatures
        let pipeline = Core.pipeline(by: "dense_backward_1");
        let queue = Core.queue()
        
        let commandBuffer = queue.makeCommandBuffer()!
        let w = min(batchSize, pipeline.threadExecutionWidth)
        let h = min(inFeatures, pipeline.maxTotalThreadsPerThreadgroup / w)

        Core.encode(
            commandBuffer: commandBuffer,
            pipeline: pipeline,
            buffers: Core.buffer(&relu), Core.buffer(&outFeatures), Core.buffer(&inFeatures), Core.buffer(param), Core.buffer(delta), Core.buffer(interScore), Core.buffer(da),
            grid: [batchSize, inFeatures, 1],
            thread: [w, h, 1]
        )

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
    
    private func backward2(_ input: NNArray, _ delta: NNArray) {
        // let row = outFeatures, col = inFeatures
        let pipeline = Core.pipeline(by: "dense_backward_2");
        let queue = Core.queue()
        
        let commandBuffer = queue.makeCommandBuffer()!
        let w = min(batchSize, pipeline.threadExecutionWidth)
        let h = min(outFeatures, pipeline.maxTotalThreadsPerThreadgroup / w)
        let d = min(inFeatures, pipeline.maxTotalThreadsPerThreadgroup / w / h)

        Core.encode(
            commandBuffer: commandBuffer,
            pipeline: pipeline,
            buffers: Core.buffer(&relu), Core.buffer(&outFeatures),  Core.buffer(&inFeatures), Core.buffer(delta), Core.buffer(input), Core.buffer(interScore), Core.buffer(dparam), Core.buffer(dbias),
            grid: [batchSize, outFeatures, inFeatures],
            thread: [w, h, d]
        )
                
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
    
    func backwardWithMetal(_ input: NNArray, _ delta: NNArray) -> NNArray {
        let inputd = input.d
        input.dim([batchSize, inFeatures])
        let da = NNArray(input.count)
        da.dim(input.d)

        backward1(da, delta)
        backward2(input, delta)
        
        input.dim(inputd)
        return da
    }
}
