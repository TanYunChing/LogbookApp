//
//  VersionListItem.swift
//  Logbook
//
//  Created by Tan Yun ching on 05/05/2022.
//

import SwiftUI

struct VersionItem: View {
    
    var version: Version
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text(version.formattedVersion)
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(version.description.isEmpty ? "N/A" : version.description)
                    .font(.caption)
                    .foregroundColor(.white)
                Text(version.formattedDate)
                    .font(.caption)
                    .foregroundColor(.white)
                    .fontWeight(.light)
                    .opacity(0.8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Color("Foreground"))
        .cornerRadius(10)
        .shadow(color: .secondary.opacity(0.4), radius: 2, x: 0.5, y: 0.5)
    }
}
