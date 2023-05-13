//
//  HomeView.swift
//  Logbook
//
//  Created by Tan Yun ching on 26/01/2022.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var projectsVM: ProjectsViewModel = ProjectsViewModel()
    @State private var showAddProjectView = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing:16) {
                    ForEach(projectsVM.projects) { item in
                        NavigationLink(destination: ProjectDetail(project: item)) {
                            ProjectListItem(project: item)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top)
            }
            .frame(maxWidth: .infinity)
            .overlay(alignment: .bottom, content: {
                AddBar(fieldText: "Add a Project")
                    .onTapGesture {
                        showAddProjectView.toggle()
                    }
            })
            .navigationTitle("Dashboard")
            .background(BackgroundImage())
        }.sheet(isPresented: $showAddProjectView) {
            AddProjectView()
        }
        .ignoresSafeArea()
        .onAppear(perform: {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.shadowColor = .clear
            appearance.titleTextAttributes = [.foregroundColor : UIColor(Color.white)]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Color.white)]
            
            let standardAppearance = UINavigationBarAppearance()
            standardAppearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            standardAppearance.titleTextAttributes = [.foregroundColor : UIColor(Color.white)]
            standardAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Color.white)]
            standardAppearance.shadowColor = .clear
            
            UINavigationBar.appearance().tintColor = UIColor(Color.white)
            UINavigationBar.appearance().standardAppearance = standardAppearance
            UINavigationBar.appearance().compactAppearance = standardAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        })
    }
}
