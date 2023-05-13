//
//  AddBar.swift
//  Logbook
//
//  Created by Tan Yun ching on 28/01/2022.
//

import SwiftUI

struct AddBar: View {
    var fieldText: String
    
    var body: some View {
        Text(fieldText)
            .fontWeight(.heavy)
            .foregroundColor(Color.white)
            .padding([.leading, .trailing], 26)
            .padding([.top, .bottom], 16)
            .background(Color("Main"))
            .cornerRadius(50)
            .shadow(radius: 3)
    }
}

struct AddBar_Previews: PreviewProvider {
    static var previews: some View {
        AddBar(fieldText: "Add a project")
    }
}
