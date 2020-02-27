//
//  SettingView.swift
//  nnPlayground
//
//  Created by Liuliet.Lee on 26/2/2020.
//  Copyright © 2020 Liuliet.Lee. All rights reserved.
//

import SwiftUI

struct SettingView: View {
    private let imageDisplayName = ["𝒙", "𝒚", "𝒙\u{00b2}", "𝒚\u{00b2}", "𝒙𝒚", "sin𝒙", "sin𝒚"]
    private let imageSystemName = ["x", "y", "x2", "y2", "xy", "sinx", "siny"]

    @Binding var learningRate: Double
    @Binding var batchSize: Double
    @Binding var noise: Double
    
    var disappear: () -> Void
    var inputToggled: (Int) -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "chevron.up")
                .scaleEffect(1.5)
                .padding(8)
                .foregroundColor(.blue)
                .onTapGesture {
                    self.disappear()
            }
            
            VStack(alignment: .trailing) {
                ForEach(0..<7, id: \.self) { i in
                    HStack {
                        Text(self.imageDisplayName[i])
                            .font(.subheadline)
                        Image(self.imageSystemName[i])
                            .resizable()
                            .frame(width: 40, height: 40)
                            .cornerRadius(8)
                            .shadow(radius: 2)
                            .opacity(Transform.transform[i].isEnable ? 1.0 : 0.2)
                            .onTapGesture {
                                self.inputToggled(i)
                        }
                    }
                }
            }
            .padding(.trailing, 16)
            
            VStack(spacing: 36) {
                VStack(spacing: 16) {
                    HStack {
                        Text("Learning Rate: ")
                            .font(.headline)
                        Text("\(learningRate * 0.00001)")
                    }
                    Slider(
                        value: $learningRate,
                        in: 1...1999.0,
                        step: 1
                    )
                }
                
                VStack(spacing: 16) {
                    HStack {
                        Text("Batch Size: ")
                            .font(.headline)
                        Text("\(Int(batchSize))")
                    }
                    Slider(
                        value: $batchSize,
                        in: 1...50.0,
                        step: 1
                    )
                }
                
                VStack(spacing: 16) {
                    HStack {
                        Text("Noise: ")
                            .font(.headline)
                        Text("\(Int(noise * 100))%")
                    }
                    Slider(
                        value: $noise,
                        in: 0.0...1.0,
                        step: 0.01
                    )
                }
            }
        }
        .padding(32)
        .background(Color.white)
    }
}

//struct SettingView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingView()
//    }
//}
