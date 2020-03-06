//
//  VisualView.swift
//  nnPlayground
//
//  Created by Liuliet.Lee on 24/2/2020.
//  Copyright © 2020 Liuliet.Lee. All rights reserved.
//

import SwiftUI

struct VisualView: View {
    
    var data: [IdentifiableSample]
    var scale: Double
    @Binding var image: UIImage

    var body: some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()

            FilledSampleView
            StrokedSampleView
        }
    }
    
    var FilledSampleView: some View {
        GeometryReader { proxy in
            ForEach (self.data) { sample in
                Circle()
                    .fill(sample.content.label > 0 ? Color.red : Color.white)
                    .frame(width: 4, height: 4)
                    .position(
                        x: proxy.size.width * (CGFloat(sample.content.position.x / self.scale) + 1.0) / 2,
                        y: proxy.size.height * (CGFloat(sample.content.position.y / self.scale) + 1.0) / 2
                )
            }
        }
    }
    
    var StrokedSampleView: some View {
        GeometryReader { proxy in
            ForEach (self.data) { sample in
                Circle()
                    .stroke(Color.black, lineWidth: 0.2)
                    .frame(width: 4, height: 4)
                    .position(
                        x: proxy.size.width * (CGFloat(sample.content.position.x / self.scale) + 1.0) / 2,
                        y: proxy.size.height * (CGFloat(sample.content.position.y / self.scale) + 1.0) / 2
                )
            }
        }
    }
}


//struct VisualView_Previews: PreviewProvider {
//    static var previews: some View {
//        VisualView()
//    }
//}
