//
//  BackgroundImage.swift
//  Logbook
//
//  Created by Tan Yun ching on 19/4/22.
//

import SwiftUI

struct BackgroundImage: View {
    var body: some View {
        Image("Background1")
            .resizable()
            .scaledToFill()
            .scaleEffect(1.1)
            .edgesIgnoringSafeArea(.all)
            .blur(radius: 10)
            .opacity(0.9)
    }
}

struct BackgroundImage_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundImage()
    }
}
