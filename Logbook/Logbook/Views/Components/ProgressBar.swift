//
//  ProgressBar.swift
//  Logbook
//
//  Created by Tan Yun ching on 12/03/2022.
//

import SwiftUI

struct ProgressBar: View {
    var progress: Double
    
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                       ZStack(alignment: .leading) {
                           Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                               .opacity(0.3)
                               .foregroundColor(.gray)
                               .opacity(0.5)
                           
                           Rectangle()
                               .fill(LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.3843137255, green: 0.5176470588, blue: 1, alpha: 1)), Color(#colorLiteral(red: 0.8509803922, green: 0.6862745098, blue: 0.8509803922, alpha: 1)), Color(#colorLiteral(red: 0.5921568627, green: 0.8509803922, blue: 0.8823529412, alpha: 1)), Color(#colorLiteral(red: 0.3843137255, green: 0.5176470588, blue: 1, alpha: 1))]), startPoint: .leading, endPoint: .trailing)
                               )
                               .frame(width: min(CGFloat(self.progress)*geometry.size.width, geometry.size.width), height: geometry.size.height)
                               
                               
                       }.cornerRadius(45)
                   }
        }.frame(maxHeight: 15)
    }
}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBar(progress: 0.8)
    }
}
