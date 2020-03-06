//
//  PlaygroundView.swift
//  nnPlayground
//
//  Created by Liuliet.Lee on 22/2/2020.
//  Copyright © 2020 Liuliet.Lee. All rights reserved.
//

import SwiftUI

public struct PlaygroundView: View {
    
    @ObservedObject var vm = PlaygroundViewModel()
    @State var showSetting = false
    
    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                HStack {
                    HStack {
                        self.LayerCountControl
                            .frame(
                                width: 100,
                                height: CGFloat(self.vm.model.desc.count * 100 + 170)
                        )
                        self.VisualizationPanel
                    }
                    .padding(.horizontal, 72)
                    .frame(width: proxy.size.width * 0.8)

                    self.ControlPanel
                        .frame(width: proxy.size.width * 0.2)
                }
            
                if self.showSetting {
                    self.SettingCover
                }
            }
        }
    }
    
    var InfoHeader: some View {
        VStack {
            VStack {
                Text("Epoch:")
                    .font(.subheadline)
                Text("\(vm.epochCount)")
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
            .padding(.bottom, 8)
            VStack {
                Text("Loss:")
                    .font(.subheadline)
                Text("\(vm.runningLoss)")
                    .font(.subheadline)
                    .fontWeight(.light)
            }
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
                    self.vm.evolvStop()
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
    
    var ControlPanel: some View {
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
    }
    
    var SettingCover: some View {
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

struct PlaygroundView_Previews: PreviewProvider {
    static var previews: some View {
        PlaygroundView()
            .previewLayout(.fixed(width: 800, height: 900))
    }
}
