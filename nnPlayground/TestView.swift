//
//  TestView.swift
//  nnPlayground
//
//  Created by Liuliet.Lee on 23/2/2020.
//  Copyright © 2020 Liuliet.Lee. All rights reserved.
//

import SwiftUI

struct TestView: View {
    
    var body: some View {
        GeometryReader { proxy in
            HStack {
                VStack(spacing: 48) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.red)
                        .scaleEffect(2)
                    Image(systemName: "minus.circle")
                        .foregroundColor(.blue)
                        .scaleEffect(2)
                }.frame(width: proxy.size.width * 0.3)
                Spacer()
                BracketPath(width: proxy.size.width * 0.6, height: proxy.size.height)
                    .stroke(lineWidth: 3)
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

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
