//
//  LogListItem.swift
//  Logbook
//
//  Created by Tan Yun ching on 05/05/2022.
//

import SwiftUI

struct LogListItem: View {
    var log: Log
    let version: Version
    @State var showSubLog = false
    @State private var selectedBlockWithLog : BlockModel? = nil
    
    @EnvironmentObject var blockVM: LogsViewModel
    @StateObject var detailViewModel: ProjectDetailViewModel = ProjectDetailViewModel()
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Circle()
                        .fill(Color(#colorLiteral(red: 0.6200000048, green: 0.6779999733, blue: 1, alpha: 1)))
                        .frame(width: 14)
                        .padding(.all, 0)
                    Text(log.datePublished)
                        .font(.caption)
                        .fontWeight(.light)
                        .padding(.all, 0)
                        .foregroundColor(.white.opacity(0.5))
                }
                HStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top) {
                            HStack(spacing: 15) {
                                VStack(alignment: .leading) {
                                    Text(log.title)
                                        .font(.body)
                                        .foregroundColor(.white)
                                        .fontWeight(.bold)
                                        .lineLimit(2)
                                        .truncationMode(.tail)
                                    
                                    Text(log.description)
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.5))
                                        .fontWeight(.light)
                                        .lineLimit(2)
                                        .truncationMode(.tail)
                                        .opacity(0.8)
                                }
                                .frame(maxWidth: 240, alignment: .topLeading)
                                
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white)
                                    .rotationEffect(showSubLog ? .degrees(180) : .degrees(0))
                                    .onTapGesture {
                                        withAnimation {
                                            showSubLog.toggle()
                                        }
                                    }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: 52)
                            .background(Color("Foreground"))
                            .cornerRadius(10)
                            .shadow(color: .secondary.opacity(0.4), radius: 2, x: 0.5, y: 0.5)
                            
                            if showSubLog {
                                VStack(alignment: .leading) {
                                    ForEach(log.blocks.filter { block in
                                        return block.blockType == .Log
                                    }, id: \.id) { block in
                                        
                                        HStack {
                                            VStack(alignment: .leading, spacing: 0) {
                                                Text(block.logBlock?.title ?? "")
                                                    .font(.body)
                                                    .fontWeight(.bold)
                                                
                                                Text(block.logBlock?.datePublished ?? "")
                                                    .font(.caption)
                                                    .fontWeight(.light)
                                                    .opacity(0.8)
                                                
                                            }
                                            .padding(.top, block.id == log.blocks[0].id ? 10 : 0)
                                            .padding([.leading, .trailing], block.logBlock?.level == 2 ? 24 : 32)
                                            
                                        }
                                        .onTapGesture {
                                            blockVM.log = block.logBlock
                                            blockVM.rootLogId = block.rootLogId
                                            selectedBlockWithLog = block
                                        }
                                        
                                        Divider()
                                        
                                    }
                                    
                                    if log.blocks.filter { block in
                                        return block.blockType == .Log
                                    }.isEmpty {
                                        Text("Nothing here yet")
                                            .font(.caption)
                                            .opacity(0.8)
                                            .padding([.leading, .trailing], 24)
                                    }
                                    
                                }
                                .foregroundColor(.primary)
                                .background(Color("Foreground"))
                                .cornerRadius(10)
                                .shadow(color: .secondary.opacity(0.4), radius: 2, x: 0.5, y: 0.5)
                            }
                        }
                        .padding(.top, 7)
                        .padding(.leading, 4)
                        .padding(.bottom, 20)
                    }
                }
                .padding(.vertical, 0)
                .padding(.leading, 10)
                .background(
                    Rectangle()
                        .fill(Color.white)
                        .padding(.vertical, 0)
                        .frame(minWidth: 2, maxWidth: 2, maxHeight: .infinity),
                    alignment: .topLeading
                )
                .padding(.leading, 6)
            }
            .padding(.all, 0)
            .padding(.leading, 10)
        }
        .padding(.vertical, 0)
        .fullScreenCover(item: $selectedBlockWithLog, onDismiss: {
            selectedBlockWithLog = nil
        }, content: { item in
            SubLogSheet(block: item, version: version, onSave: { subLog in
                // detailViewModel.addLog(log: self.log, onAdded: { _ in })
            }).environmentObject(blockVM)
        })
    }
}
