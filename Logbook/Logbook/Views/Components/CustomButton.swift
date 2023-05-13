//
//  CustomButton.swift
//  Logbook
//
//  Created by Tan Yun ching on 06/05/2022.
//

import SwiftUI

struct CustomButton: View {
    var systemName: String = "play"
    var label: String = ""
    var fontSize: CGFloat = 20
    var color: Color = .white
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(label)
            Image(systemName: systemName)
                .font(.system(size: fontSize))
                .foregroundColor(color)
            
        }
    }
}
