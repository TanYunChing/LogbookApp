//
//  Icon.swift
//  Logbook
//
//  Created by Tan Yun ching on 27/01/2022.
//

import SwiftUI

struct Icon: View {
    var iconName : String
    @Binding var currentlyEditing: Bool
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 12)
                .background(Color("tertiaryBackground").opacity(0.9).blur(radius: 5.0))

            Image(systemName: iconName)
                .foregroundColor(.white)
                .font(.system(size: 17, weight: .medium))
        }.overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white, lineWidth: 1)
                .blendMode(.overlay)
            
        ).frame(width: 36, height: 36, alignment: .center)
            .padding()
    }
}

struct Icon_Previews: PreviewProvider {
    static var previews: some View {
        Icon(iconName: "plus", currentlyEditing: .constant(true))
    }
}
