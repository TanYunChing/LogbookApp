//
//  ProjectCards.swift
//  Logbook
//
//  Created by Tan Yun ching on 26/01/2022.
//

import SwiftUI

struct ProjectListItem: View {
    
    var project: Project
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16){
            Text(project.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(project.description)
                .font(.body)
                .lineLimit(3)
            
            Spacer()
            
            HStack(spacing: 3) {
                Image(systemName: "clock")
                    .font(.footnote)
                    .opacity(0.3)
                Text("Created")
                    .font(.caption2)
                    .fontWeight(.thin)
                Text(project.datePublished)
                    .font(.caption2)
                    .fontWeight(.thin)
            }
        }
        .foregroundColor(.white)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 160)
        .background(Color("Foreground"))
        .cornerRadius(10)
    }
}
