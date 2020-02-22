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
            
            VisualView(
                data: vm.model.data.enumerated().map { (index, elem) in
                    IdentifiableSample(id: index, content: elem)
                },
                scale: DataGenerator.dataScale,
                image: $vm.displayImage
            )
                .frame(width: 300, height: 300)
                .cornerRadius(12)
            
            Button(vm.evolving ? "Pause" : "Start") {
                self.vm.evolvToggle()
            }
            .font(.system(size: 36))
        }
    }
}

struct PlaygroundView_Previews: PreviewProvider {
    static var previews: some View {
        PlaygroundView()
    }
}
