//
//  DetailBar.swift
//  Logbook
//
//  Created by Tan Yun ching on 26/01/2022.
//

import SwiftUI

struct DetailBar: View {
    @Binding var selectedTab: Bar
    var project: Project
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack (alignment: .leading) {
                Text(project.title)
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(project.description)
                    .font(.body)
                    .foregroundColor(.white)
                    .opacity(0.7)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 5)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                
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
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                .padding(.top, 20)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background(.ultraThinMaterial)
            .mask(RoundedRectangle(cornerRadius: 30))
            .padding()
            
            HStack(alignment: .bottom) {
                Spacer()
                Button {
                    withAnimation {
                        selectedTab = .overview
                    }
                } label: {
                    VStack(spacing: 0) {
                        Text("Overview")
                            .font(.callout.bold())
                            .padding(15)
                        
                        Rectangle()
                            .fill(.primary)
                            .frame(maxWidth: 110, maxHeight: 4)
                            .cornerRadius(20)
                            .opacity(selectedTab == .overview ? 1:0)
                    }
                }
                Spacer()
                Button {
                    withAnimation {
                        selectedTab = .version
                    }
                } label: {
                    VStack(spacing: 0) {
                        Text("Version")
                            .font(.callout.bold())
                            .padding(15)
                        
                        Rectangle()
                            .fill(.primary)
                            .frame(maxWidth: 110, maxHeight: 4)
                            .cornerRadius(20)
                            .opacity(selectedTab == .version ? 1:0)
                    }
                }
                Spacer()
            }
            .foregroundColor(.white.opacity(0.7))
            .background(Color("Main"))
            .cornerRadius(20)
            .padding(.horizontal, 6)
            
        }
    }
}

enum Bar: String {
    case overview
    case version
}
