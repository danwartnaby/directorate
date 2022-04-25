//
//  SpinnerView.swift
//  Directorate
//
//  Created by Dan Wartnaby on 21/04/2022.
//

import SwiftUI


struct SpinnerProgressViewStyle: ProgressViewStyle {
    var lineWeight: CGFloat = 5
    var scale: CGFloat = 1.0
    var color: Color
    var showPercent: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Circle()
                .trim(from: 0.0, to: CGFloat(configuration.fractionCompleted ?? 0))
                .stroke(color, style: StrokeStyle(lineWidth: lineWeight, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}


struct SpinnerProgressView: View {
    static let ChannelsCircularProgressSize: CGFloat = 110

    @State var isRotated: Bool
    
    var scale: CGFloat = 1.0
    
    var progress: Double = 0.0
    
    var indeterminate: Bool = false
        
    init(progress: Double) {
        self.progress = progress
        self.isRotated = false
    }
    
    init(indeterminate: Bool, scale: CGFloat) {
        self.indeterminate = indeterminate
        self.progress = 0.25
        self.isRotated = false
        self.scale = scale
    }
    
    private func random() -> Double {
        return Double("\(0).\(Int.random(in: 0...99))")!
    }
    
    @ViewBuilder
    func progressRing(_ color: Color, showPercent: Bool = false) -> some View {
        
        if indeterminate {
            ProgressView(value: progress, total: 1.0)
                .progressViewStyle(SpinnerProgressViewStyle(scale: scale, color: color, showPercent: false))
                .rotationEffect(Angle.degrees(isRotated ? 360 : 0))
                .animation(Animation.linear(duration: 0.5 + random())
                            .repeatForever(autoreverses: false))
        }
        else {
            ProgressView(value: progress, total: 1.0)
                .progressViewStyle(SpinnerProgressViewStyle(scale: scale, color: color, showPercent: false))
        }
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            progressRing(Color("Spinner_4")).padding(0)
            progressRing(Color("Spinner_3")).padding(14)
            progressRing(Color("Spinner_2")).padding(28)
            progressRing(Color("Spinner_1"), showPercent: !indeterminate).padding(42)
        }
        .offset(x: 0, y: 45)
        .onAppear() {
            self.isRotated = true
        }
    }
}
