//
//  VisualizationPanel.swift
//  nnPlayground
//
//  Created by Liuliet.Lee on 29/2/2020.
//  Copyright © 2020 Liuliet.Lee. All rights reserved.
//

import SwiftUI

extension PlaygroundView {
    
    var VisualizationPanel: some View {
        VStack(spacing: 0) {
            ForEach(0..<vm.model.desc.count, id: \.self) { layerID in
                VisualLayer(layerID: layerID, canAdjustLayer: self.canAdjustLayer, vm: self.vm)
            }
            
            FinalVisualPart
        }
    }
    
    var FinalVisualPart: some View {
        VStack(spacing: 0) {
            ConnectView(
                inputNeu: vm.model.desc.last!,
                outputNeu: 1,
                param: vm.model.model.layers.last!.param)
                .frame(height: 50)
            VisualView(
                data: vm.model.data.enumerated().map { (index, elem) in
                    IdentifiableSample(id: index, content: elem)
                },
                scale: DataGenerator.dataScale,
                image: $vm.mainImage)
                .frame(width: 180, height: 180)
                .cornerRadius(12)
                .shadow(radius: 2)
                .onTapGesture {
                    if self.canChangeDataset {
                        self.vm.evolvStop()
                        DataGenerator.nextType()
                        self.vm.model.data = DataGenerator.getTrainingData()
                        self.vm.model.model = SequentialModel(self.vm.model.desc)
                        self.vm.newModelGenerated()
                    }
            }
        }
    }
    
    struct VisualLayer: View {
        var layerID: Int
        var canAdjustLayer: Bool
        @ObservedObject var vm: PlaygroundViewModel

        var body: some View {
            VStack(spacing: 0) {
                if layerID < self.vm.model.desc.count {
                    VisualRow(layerID: layerID, canAdjustLayer: canAdjustLayer, vm: self.vm)
                }
                
                if layerID < self.vm.model.desc.count - 1 {
                    ConnectView(
                        inputNeu: self.vm.model.desc[layerID],
                        outputNeu: self.vm.model.desc[layerID + 1],
                        param: self.vm.model.model.layers[layerID].param)
                        .frame(height: 50)
                }
            }
        }
    }
    
    struct VisualRow: View {
        var layerID: Int
        var canAdjustLayer: Bool
        @ObservedObject var vm: PlaygroundViewModel

        var body: some View {
            HStack(spacing: 20) {
                if layerID > 0 && canAdjustLayer {
                    Image(systemName: "minus.circle")
                        .foregroundColor(.blue)
                        .scaleEffect(1.4)
                        .onTapGesture {
                            self.vm.dropNeuron(at: self.layerID)
                    }
                }
                if layerID < self.vm.model.desc.count {
                    ForEach(0..<self.vm.model.desc[layerID], id: \.self) { neuID in
                        Image(uiImage: self.vm.visualImages[self.layerID][neuID])
                            .resizable()
                            .frame(width: 50, height: 50)
                            .cornerRadius(8)
                            .shadow(radius: 2)
                    }
                }
                if layerID > 0 && canAdjustLayer {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.red)
                        .scaleEffect(1.4)
                        .onTapGesture {
                            self.vm.addNeuron(at: self.layerID)
                    }
                }
            }
        }
    }
}
