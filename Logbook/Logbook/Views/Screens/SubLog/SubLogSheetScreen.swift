//
//  SubLogSheet.swift
//  Logbook
//
//  Created by Tan Yun ching on 26/03/2022.
//

import SwiftUI

struct SubLogSheet: View {
    var block: BlockModel
    let version: Version
    var onSave: (Log) -> Void
    
    // AudioView
    @StateObject var audioModel = AudioModel()
    @StateObject var audioModelForCell = AudioModel()
    
    @State var title: String = ""
    @State var description: String = "Description"
    @State var barHeight: CGFloat = .zero
    @State var offset: CGFloat = .zero
    @State var textViewHeight: CGFloat =  .zero
    @State var textViewWidth: CGFloat =  .zero
    @State var text: String = ""
    
    @StateObject var blockVM: LogsViewModel = LogsViewModel()
    @StateObject var detailViewModel: ProjectDetailViewModel = ProjectDetailViewModel()
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    
    init(block: BlockModel, version: Version, onSave: @escaping (Log) -> Void) {
        // See: https://stackoverflow.com/a/64597047/4951640
        UITextView.appearance().textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        // Prevent scrolling inside ScrollView
        // See: https://stackoverflow.com/a/70389058
        UITextView.appearance().textDragInteraction?.isEnabled = false
        
        self.block = block
        self.version = version
        self.onSave = onSave
    }
    
    var mainContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            let titleBinding = Binding<String>(
                get: {
                    blockVM.log?.title ?? ""
                }, set: {
                    blockVM.log?.title = $0
                })
            
            let descBinding = Binding<String>(
                get: {
                    blockVM.log?.description ?? ""
                }, set: {
                    blockVM.log?.description = $0
                })
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 3) {
                    Image(systemName: "clock")
                        .font(.footnote)
                    Text("Created")
                        .font(.caption2)
                        .fontWeight(.light)
                    Text(blockVM.log?.datePublished ?? "")
                        .font(.caption2)
                        .fontWeight(.light)
                }
                .padding(.top, 20)
                .padding(.bottom)
                
                TitleTextField("Title", text: titleBinding)
                    .padding(EdgeInsets(top: 0, leading: -4, bottom: 0, trailing: 0))
                
            }.padding(.horizontal, 20)
            
            GeometryReader { geometry in
                ScrollViewReader { proxy in
                    ScrollView(.vertical) {
                        MultilineTextField("Description", text: descBinding)
                            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
                            .font(.callout)
                        
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(blockVM.log?.blocks ?? [], id: \.id) { block in
                                let type = block.blockType
                                switch type {
                                case .text:
                                    Text(block.content)
                                case .Audio:
                                    AudioCellView(audioBlock: block.audioBlock, action: {
                                        withAnimation {
                                            blockVM.removeBlock(block: block)
                                        }
                                    })
                                    .environmentObject(audioModelForCell)
                                    .frame(width: geometry.size.width / 1.3)
                                case .File:
                                    FileItemView(action: {
                                        withAnimation {
                                            blockVM.removeBlock(block: block)
                                        }
                                    }, document: block.fileUrl!)
                                case .Image:
                                    ImageItemView(image: block.imageBlock, url: block.imageUrl, action: {
                                        withAnimation {
                                            blockVM.removeBlock(block: block)
                                        }
                                    }).frame(width: geometry.size.width / 1.5 , height: geometry.size.width / 1.5)
                                case .Log:
                                    LogItemView(block: block, version: version, action: {
                                        withAnimation {
                                            blockVM.removeBlock(block: block)
                                        }
                                    }, onUpdateBlock: { block in
                                        // blockVM.updateBlock(updatedBlock: block)
                                    })
                                }
                            }
                        }
                        .padding([.horizontal], 20)
                        .padding(.vertical, 10)
                        .transition(.move(edge: .leading))
                        // End VStack
                    }
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 0,
                        maxHeight: .infinity,
                        alignment: .topLeading
                    )
                    .onChange(of: (blockVM.log?.blocks ?? []).count, perform: { _ in
                        // Auto scroll to bottom when new item is appended to the list
                        if let id = blockVM.log?.blocks.last?.id {
                            withAnimation {
                                proxy.scrollTo(id)
                            }
                        }
                    })
                    // End ScrollView
                }
            }
        }
        .ignoresSafeArea()
        .padding(.vertical, 10)
        .onFirstAppear {
            blockVM.log = block.logBlock
            blockVM.rootLogId = block.rootLogId
            blockVM.loadSubLog(blockId: block.id)
            detailViewModel.setVersion(version: version)
        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .disabled(detailViewModel.showProgressView || blockVM.showProgressView)
        // End VStack
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .center) {
                ZStack(alignment: .bottom) {
                    mainContent
                        .padding(.bottom, 55)
                        .background(Color("Main"))
                        .foregroundColor(.white)
                    
                    BottomToolbar(version: version, audioModel: audioModel)
                        .environmentObject(blockVM)
                        .disabled(detailViewModel.showProgressView || blockVM.showProgressView)
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    trailing: Button(action: {
                        self.detailViewModel.addSubLog(block: block, log: blockVM.log, onAdded: { log in
                            self.onSave(log)
                            self.dismiss.callAsFunction()
                        })
                    }, label: {
                        Text("Done")
                            .bold()
                            .foregroundColor(.white)
                    })
                )
                .interactiveDismissDisabled()
                
                if detailViewModel.showProgressView || blockVM.showProgressView {
                    ProgressView()
                        .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 30)
                        .background(
                            VisualEffect(style: .light)
                                .background(Color.black.opacity(0.2))
                            
                        )
                        .cornerRadius(4)
                }
            }
            .onAppear(perform: {
                let appearance = UINavigationBarAppearance()
                appearance.backgroundColor = UIColor(Color("Main"))
                appearance.shadowColor = .clear
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
            })
        }
    }
}
