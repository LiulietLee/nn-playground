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
    @State var showSetting = false
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                HStack {
                    HStack {
                        self.LayerCountControl
                            .frame(
                                width: 100,
                                height: CGFloat(self.vm.model.desc.count * 100 + 170)
                        )
                        self.ControlPanel
                    }
                    .padding(.horizontal, 72)
                    .frame(width: proxy.size.width * 0.8)

                    VStack(alignment: .center) {
                        Image(systemName: "slider.horizontal.3")
                            .scaleEffect(2)
                            .foregroundColor(.blue)
                            .padding(.bottom, 64)
                            .padding(.trailing, 36)
                            .onTapGesture {
                                self.showSetting.toggle()
                        }
                        
                        self.InfoHeader
                            .padding(.trailing, 32)
                            .padding(.vertical, 16)

                        self.ProgressControl
                            .padding(.trailing, 32)
                            .padding(.top, 32)
                    }
                    .frame(width: proxy.size.width * 0.2)
                }
            
                if self.showSetting {
                    VStack {
                        SettingView(
                            learningRate: .init(
                                get: { self.vm.learningRateScaler },
                                set: { self.vm.learningRateScaler = $0 }
                            ),
                            batchSize: .init(
                                get: { self.vm.batchSize },
                                set: { self.vm.batchSize = $0 }
                            ),
                            noise: .init(
                                get: { self.vm.dataNoise },
                                set: { self.vm.dataNoise = $0 }
                            ),
                            disappear: {
                                self.showSetting.toggle()
                            },
                            inputToggled: { i in
                                self.vm.toggleInput(id: i)
                            }
                        )
                        
                        Spacer()
                    }
                }
            }
        }
    }
    
    var InfoHeader: some View {
        VStack {
            VStack {
                Text("Epoch: ")
                    .font(.title)
                Text("\(vm.epochCount)")
                    .font(.title)
                    .fontWeight(.bold)
            }
            .padding(.bottom, 8)
            VStack {
                Text("Loss: ")
                    .font(.title)
                Text("\(vm.runningLoss)")
                    .font(.title)
                    .fontWeight(.light)
            }
        }
    }
    
    var ControlPanel: some View {
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
                                .frame(width: 50, height: 50)
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
                            .frame(height: 50)
                    }
                }
            }
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
        }
    }
    
    var ProgressControl: some View {
        VStack(alignment: .center, spacing: 48) {
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
    
    var LayerCountControl: some View {
        GeometryReader { proxy in
            HStack {
                VStack(spacing: 48) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.red)
                        .scaleEffect(2)
                        .onTapGesture {
                            self.vm.addLayer()
                    }
                    Image(systemName: "minus.circle")
                        .foregroundColor(.blue)
                        .scaleEffect(2)
                        .onTapGesture {
                            self.vm.dropLayer()
                    }
                }
                .frame(width: proxy.size.width * 0.3)
                Spacer()
                BracketPath(width: proxy.size.width * 0.6, height: proxy.size.height)
                    .stroke(Color.gray, lineWidth: 2)
                    .frame(width: proxy.size.width * 0.6, height: proxy.size.height)
            }
        }
    }
    
    struct BracketPath: Shape {
        let width: CGFloat
        let height: CGFloat
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let w = width
            let h = height
            
            path.move(to: CGPoint(x: w, y: 0))
            path.addQuadCurve(
                to: CGPoint(x: w / 2, y: 60),
                control: CGPoint(x: w / 2, y: 0)
            )
            path.addLine(to: CGPoint(x: w / 2, y: h / 2 - 60))
            path.addQuadCurve(
                to: CGPoint(x: 0, y: h / 2),
                control: CGPoint(x: w / 2, y: h / 2)
            )
            path.addQuadCurve(
                to: CGPoint(x: w / 2, y: h / 2 + 60),
                control: CGPoint(x: w / 2, y: h / 2)
            )
            path.addLine(to: CGPoint(x: w / 2, y: h - 60))
            path.addQuadCurve(
                to: CGPoint(x: w, y: h),
                control: CGPoint(x: w / 2, y: h)
            )
            
            return path
        }
    }
}

struct PlaygroundView_Previews: PreviewProvider {
    static var previews: some View {
        PlaygroundView()
            .previewLayout(.fixed(width: 800, height: 900))
    }
}
