//
//  Details.swift
//  Logbook
//
//  Created by Tan Yun ching on 26/01/2022.
//

import SwiftUI

struct ProjectDetail: View {
    
    var project: Project
    @State var selectedTab: Bar = .version
    
    //Overview
    @StateObject private var projectsVM = ProjectsViewModel()
    @State private var duration: Double = 0
    @State private var progress: Double = 0
    
    //Version List
    @StateObject var versionViewModel = VersionViewModel()
    @State var isShowing: Bool = false
    @State var description: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            DetailBar(selectedTab: $selectedTab, project: project)
            
            Spacer()
            
            switch selectedTab {
            case .overview:
                overView
                    .padding(.vertical, 20)
            case .version:
                versionList
                    .padding(.vertical, 20)
            }
        }
        .navigationTitle("Project Detail")
        .background(BackgroundImage())
    }
    
    
    
    var overView: some View {
        ScrollView {
            VStack(spacing: 5) {
                
                // MARK: - Progression Bar
                VStack(spacing: 7) {
                    HStack(alignment: .bottom) {
                        Text("Progression").font(.body).bold()
                        Spacer()
                        Text((duration * (1-progress)).rounded().formatted()).font(.largeTitle.bold()) + Text(" day left").font(.footnote)
                        
                        
                    }.frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal, 25)
                    
                    ProgressBar(progress: progress)
                        .padding(.horizontal)
                    
                    HStack {
                        Text((duration * progress).rounded().formatted()) + Text(" / ") + Text(duration.formatted()) +
                        Text(" days")
                        
                    }.font(.footnote).opacity(0.4)
                        .frame(maxWidth:.infinity, alignment: .trailing)
                        .padding(.horizontal, 25)
                    
                }
                .frame(minHeight: 160)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .padding(5)
            }
            .onFirstAppear {
                self.duration = projectsVM.getDuration(createdAt: project.createdAt, endDate: project.endDate)
                self.progress = projectsVM.getProgress(duration: self.duration, current: Date.now, endDate: project.endDate)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal)
        }
    }
    
    var versionList: some View {
        ZStack {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(versionViewModel.list) { version in
                        NavigationLink(destination: VersionDetailPage(version: version)) {
                            VersionItem(version: version)
                        }
                    }
                    if versionViewModel.list.isEmpty && !versionViewModel.showProgressView {
                        VStack(alignment: .center) {
                            Text("Nothing here yet")
                                .font(.callout)
                                .foregroundColor(.white)
                                .opacity(0.7)
                            Button(action: {
                                description = ""
                                isShowing = true
                            }, label: {
                                Text("Tap to create a new Version")
                                    .bold()
                                    .foregroundColor(Color(#colorLiteral(red: 0.6200000048, green: 0.6779999733, blue: 1, alpha: 1)))
                                    .opacity(0.7)
                            })
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.horizontal)
                .foregroundColor(.black)
            }
            .alert(isPresented: $isShowing, AlertConfig(title: "Describe This Version", placeholder: "e.g. updated xxx", action: { text in
                if text?.isEmpty == false {
                    versionViewModel.createVersion(projectId: project.id!, description: text ?? "")
                }
            }))
            .onFirstAppear {
                versionViewModel.fetchVersionList(projectId: project.id!)
            }
            .overlay(alignment: .bottom, content: {
                AddBar(fieldText: "+ New Version")
                    .onTapGesture {
                        description = ""
                        isShowing = true
                    }
            })
            .disabled(versionViewModel.showProgressView)
            
            if versionViewModel.showProgressView {
                ProgressView()
                    .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 30)
                    .background(
                        VisualEffect(style: .light)
                            .background(Color.black.opacity(0.2))
                        
                    )
                    .cornerRadius(4)
            }
        }
    }
}
