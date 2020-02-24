//
//  PlaygroundView.swift
//  nnPlayground
//
//  Created by Liuliet.Lee on 22/2/2020.
//  Copyright © 2020 Liuliet.Lee. All rights reserved.
//

import SwiftUI

struct PlaygroundView: View {
    
    @ObservedObject var vm = PlaygroundViewModel()
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("Epoch: ")
                        .font(.title)
                    Text("\(vm.epochCount)")
                        .font(.title)
                        .fontWeight(.light)
                }
                HStack {
                    Text("Loss: ")
                        .font(.title)
                    Text("\(vm.runningLoss)")
                        .font(.title)
                        .fontWeight(.light)
                }
            }
            
            VStack(spacing: 0) {
                ForEach(0..<vm.model.desc.count, id: \.self) { layerID in
                    VStack(spacing: 0) {
                        HStack(spacing: 20) {
                            if layerID > 0 {
                                Image(systemName: "minus.circle")
                                    .foregroundColor(.blue)
                                    .scaleEffect(1.4)
                                    .onTapGesture {
                                    self.vm.dropNeuron(at: layerID)
                                }
                            }
                            ForEach(0..<self.vm.model.desc[layerID], id: \.self) { neuID in
                                Image(uiImage: self.vm.visualImages[layerID][neuID])
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(8)
                                    .shadow(radius: 2)
                            }
                            if layerID > 0 {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.red)
                                    .scaleEffect(1.4)
                                    .onTapGesture {
                                    self.vm.addNeuron(at: layerID)
                                }
                            }
                        }
                        if layerID < self.vm.model.desc.count - 1 {
                            ConnectView(
                                inputNeu: self.vm.model.desc[layerID],
                                outputNeu: self.vm.model.desc[layerID + 1],
                                param: self.vm.model.model.layers[layerID].param)
                                .frame(height: 80)
                        }
                    }
                }
                ConnectView(
                    inputNeu: vm.model.desc.last!,
                    outputNeu: 1,
                    param: vm.model.model.layers.last!.param)
                    .frame(height: 80)
                VisualView(
                    data: vm.model.data.enumerated().map { (index, elem) in
                        IdentifiableSample(id: index, content: elem)
                    },
                    scale: DataGenerator.dataScale,
                    image: $vm.mainImage)
                    .frame(width: 200, height: 200)
                    .cornerRadius(12)
                    .shadow(radius: 2)
            }
            
            HStack(alignment: .center, spacing: 48) {
                Image(systemName: "gobackward")
                    .foregroundColor(.blue)
                    .scaleEffect(1.8)
                    .padding(.trailing, 3)
                    .onTapGesture {
                        self.vm.evolvRestart()
                }
                Image(systemName: vm.evolving ? "pause.fill" : "play.fill")
                    .foregroundColor(.blue)
                    .scaleEffect(3)
                    .onTapGesture {
                        self.vm.evolvToggle()
                }
                Image(systemName: "forward.end")
                    .foregroundColor(.blue)
                    .scaleEffect(2)
                    .onTapGesture {
                        if self.vm.evolving {
                            self.vm.evolvPause()
                        }
                        self.vm.evolvOnce()
                }
            }
            .padding(.top, 36)
        }
    }
}

struct PlaygroundView_Previews: PreviewProvider {
    static var previews: some View {
        PlaygroundView()
            .previewLayout(.fixed(width: 900, height: 1280))
    }
}
