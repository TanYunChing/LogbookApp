//
//  VersionDetailPage.swift
//  Logbook
//
//  Created by Tan Yun ching on 26/01/2022.

import SwiftUI

struct VersionDetailPage: View {
    
    var version: Version
    
    @StateObject var blockVM = LogsViewModel()
    @StateObject var projectDetailVM = ProjectDetailViewModel()
    
    @State var showCommit = false
    @State private var selectedItem : Log? = nil
  
    
    var body: some View {
        logList
            .navigationTitle("\(version.formattedVersion)'s Logs")
            .background(BackgroundImage())
    }
    
    var logList: some View {
        ScrollView {
            VStack(spacing: 0) {
                LazyVStack(spacing: 0) {
                    HStack(alignment: .center) {
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 16)
                    
                    ForEach(projectDetailVM.logs) { log in
                        LogListItem(log: log, version: version)
                            .onTapGesture() {
                                blockVM.log = log
                                blockVM.rootLogId = log.id!
                                selectedItem = log
                            }
                            .environmentObject(blockVM)
                    }
                }
            }
            .onFirstAppear(perform: {
                projectDetailVM.version = version
                projectDetailVM.loadLogs()
            })
            .disabled(projectDetailVM.showProgressView)
            .fullScreenCover(item: $selectedItem, onDismiss: {
                selectedItem = nil
            }, content: { item in
                LogSheet(log: item, version: version, onSave: { _ in })
                    .environmentObject(blockVM)
            })
            
            if projectDetailVM.showProgressView {
                ProgressView()
                    .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 14)
                    .cornerRadius(4)
            }
        }
        .overlay(alignment: .bottom, content: {
                AddBar(fieldText: "+ New Log")
                    .onTapGesture() {
                        let log = Log(projectId: version.projectId, versionId: version.id!, title: "", description: "", blocks: [])
                        blockVM.log = log
                        blockVM.rootLogId = log.id!
                        selectedItem = log
                    }
            })
    }
}
