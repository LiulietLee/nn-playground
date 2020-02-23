//
//  ConnectView.swift
//  nnPlayground
//
//  Created by Liuliet.Lee on 24/2/2020.
//  Copyright © 2020 Liuliet.Lee. All rights reserved.
//

import SwiftUI

struct ConnectView: View {
    var inputNeu: Int
    var outputNeu: Int
    var param: [[Double]]
    
    var body: some View {
        GeometryReader { proxy in
            ForEach(0..<self.inputNeu, id: \.self) { i in
                ForEach(0..<self.outputNeu, id: \.self) { j in
                    ConnectedPath(
                        from: CGPoint(
                            x: proxy.size.width / 2 - self.getMidOf(kth: i, total: self.inputNeu),
                            y: 0),
                        to: CGPoint(
                            x: proxy.size.width / 2 - self.getMidOf(kth: j, total: self.outputNeu),
                            y: proxy.size.height))
                        .stroke(
                            self.getColorBy(parameter: self.param[j][i]),
                            lineWidth: 4)
                }
            }
        }
    }
    
    func getColorBy(parameter: Double) -> Color {
        let elem = atan(parameter) * 2 / .pi
        
        if elem > 0.0 {
            return Color(red: 1.0, green: (1 - elem), blue: (1 - elem))
        } else {
            return Color(red: (1 + elem), green: 1.0, blue: (1 + elem))
        }
    }
    
    func getMidOf(kth k: Int, total: Int) -> CGFloat {
        let interval = 60 + 20
        if total % 2 == 0 {
            let left = (total / 2 - 1) * interval + interval / 2
            return CGFloat(left - interval * k)
        } else {
            let left = (total / 2) * interval
            return CGFloat(left - interval * k)
        }
    }
    
    struct ConnectedPath: Shape {
        let from: CGPoint
        let to: CGPoint
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let mid = (from.y + to.y) / 2
            let offsetY = (mid - from.y) * 2 / 3
            
            path.move(to: from)
            path.addQuadCurve(
                to: CGPoint(x: (from.x + to.x) / 2, y: mid),
                control: CGPoint(x: from.x, y: from.y + offsetY)
            )
            path.addQuadCurve(
                to: to,
                control: CGPoint(x: to.x, y: to.y - offsetY)
            )

            return path
        }
    }
}


struct ConnectView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectView(
            inputNeu: 3,
            outputNeu: 4,
            param: [[Double]](repeating: [Double](repeating: 1.0, count: 3), count: 4))
    }
}
