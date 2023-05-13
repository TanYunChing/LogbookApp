//
//  ProgressRing.swift
//  Logbook
//
//  Created by Tan Yun ching on 12/03/2022.
//

import SwiftUI

struct ProgressRing: View {
    var progress: Double
    
    
    var body: some View {
        ZStack {
            // MARK: Placeholder Ring
            Circle()
                .stroke(lineWidth: 20)
                .foregroundColor(.gray)
                .opacity(0.1)
            
            
            // MARK: Colored Ring
            Circle()
                .trim(from: 0.0, to: min(self.progress, 1.0))
                .stroke(AngularGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.3843137255, green: 0.5176470588, blue: 1, alpha: 1)), Color(#colorLiteral(red: 0.8509803922, green: 0.6862745098, blue: 0.8509803922, alpha: 1)), Color(#colorLiteral(red: 0.5921568627, green: 0.8509803922, blue: 0.8823529412, alpha: 1)), Color(#colorLiteral(red: 0.3843137255, green: 0.5176470588, blue: 1, alpha: 1))]), center: .center), style: StrokeStyle(lineWidth: 15.0, lineCap: .round, lineJoin: .round))
                .rotationEffect(Angle(degrees: 270))
                .animation(.easeInOut(duration: 1.0), value: 0.8)
                           
                           
            // MARK: Percentage
            VStack(spacing: 30) {
                Text(String(format: "%.0f %%", min(self.progress, 1.0)*100.0))
                                .font(.largeTitle)
                                .bold()
                
                
            }
        }
        .frame(width: 200, height: 200)
        .padding()
    }
}


struct ProgressRing_Previews: PreviewProvider {
    static var previews: some View {
        ProgressRing(progress: 0.4)
    }
}
