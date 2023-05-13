//
//  LogSheet.swift
//  Logbook
//
//  Created by Tan Yun ching on 26/01/2022.
//

import SwiftUI

struct LogSheet: View {
    var log: Log
    let version: Version
    var onSave: (Log) -> Void
    
    // AudioView
    @StateObject var audioModel = AudioModel()
    @StateObject var audioModelForCell = AudioModel()
    @StateObject var logModelForCell = LogsViewModel()
    
    @State var title: String = ""
    @State var description: String = "Description"
    @State var barHeight: CGFloat = .zero
    @State var offset: CGFloat = .zero
    @State var textViewHeight: CGFloat =  .zero
    @State var textViewWidth: CGFloat =  .zero
    @State var text: String = ""
    @State private var selectedBlock: BlockModel? = nil

    @EnvironmentObject var projectsVM: ProjectsViewModel
    @EnvironmentObject var blockVM: LogsViewModel
    @StateObject var detailViewModel: ProjectDetailViewModel = ProjectDetailViewModel()
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    
    init(log: Log, version: Version, isSubComponent: Bool = false, onSave: @escaping (Log) -> Void) {
        // See: https://stackoverflow.com/a/64597047/4951640
        UITextView.appearance().textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        // Prevent scrolling inside ScrollView
        // See: https://stackoverflow.com/a/70389058
        UITextView.appearance().textDragInteraction?.isEnabled = false
        
        self.log = log
        self.version = version
        self.onSave = onSave
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
                        .disabled(detailViewModel.showProgressView)
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    leading: Button(action: {
                        dismiss()
                    }, label: {
                        Text("Cancel")
                            .bold()
                            .foregroundColor(.white)
                    }),
                    trailing: Button(action: {
                        self.detailViewModel.commit(log: blockVM.log, onAdded: { log in
                            self.onSave(log)
                        })
                        dismiss()
                    }, label: {
                        Text("Commit")
                            .bold()
                            .foregroundColor(.white)
                    })
                )
                .onAppear(perform: {
                    let appearance = UINavigationBarAppearance()
                    appearance.backgroundColor = UIColor(Color("Main"))
                    appearance.shadowColor = .clear
                    UINavigationBar.appearance().standardAppearance = appearance
                    UINavigationBar.appearance().scrollEdgeAppearance = appearance
                })
                .interactiveDismissDisabled()
                
                if detailViewModel.showProgressView {
                    
                    ProgressView()
                        .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 30)
                        .background(
                            VisualEffect(style: .light)
                                .background(Color.black.opacity(0.2))
                            
                        )
                        .cornerRadius(4)
                }
                
                if blockVM.showComponentsView {
                    componentsView
                        .environmentObject(logModelForCell)
                }
            }
        }
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
                        
                        HStack(){
                            HStack(){
                                Text("Components")
                                    .font(.callout)
                                    .fontWeight(.semibold)
                                
                                
                                Text(String(blockVM.log?.blocks.filter { block in
                                                                return block.blockType == .Log
                                }.count ?? 0))
                                    .font(.footnote.bold())
                                    .foregroundColor(.primary)
                                    .padding(5)
                                    .background(){
                                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                                            .fill(.white)
                                            .padding(.vertical, 4)
                                    }
                                    .cornerRadius(20)
                                    .padding(.vertical,10)
                                    
                                
                                Spacer()
                                
                            }.frame(maxWidth : .infinity)
                                .padding(.leading, 10)
                                .padding(.horizontal)
                                .background(.ultraThinMaterial)
                                .cornerRadius(10)
                                .offset(x: -6)
                                .onTapGesture(){
                                    withAnimation(.interactiveSpring(response: 0.8, dampingFraction: 0.7, blendDuration: 0.7)){
                                        blockVM.showComponentsView = true
                                    }
                                    
                                }
                            
                            
                            Spacer()
                                .frame(maxWidth: .infinity)
                            
                        }
                        
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
                                    .environmentObject(logModelForCell)
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
            detailViewModel.setVersion(version: version)
            blockVM.loadBlocks(isSubLog: false)
        }
        .onDisappear(){
            blockVM.showComponentsView = false
        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .disabled(detailViewModel.showProgressView)
        // End VStack
    }
    
    var componentsView: some View {
        ZStack(alignment: .topTrailing) {
            Rectangle()
                .fill(.ultraThinMaterial)
                .onTapGesture {
                    blockVM.showComponentsView = false
                }
                .opacity(blockVM.showComponentsView ? 0.8 : 0)
                .ignoresSafeArea()
            
            
            VStack(alignment: .leading){
                ForEach(blockVM.log?.blocks.filter { block in
                    return block.blockType == .Log
                } ?? [], id: \.id) { block in
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text(block.logBlock?.title ?? "")
                            .frame(alignment: .leading)
                            .padding(.leading, 5)
                            .onTapGesture(){
                                selectedBlock = block
                            }
                    }
                    .font(.callout)
                    .foregroundColor(.primary)
                    
                    Divider()
                        .padding(.vertical, 4)
                }
                Spacer()
            }
            .padding()
            .frame(maxWidth: 250)
            .frame(minHeight: 150)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .offset(x: 30)
            .offset(y: 50)
            .transition(.moveAndFade)
            .sheet(item: $selectedBlock, onDismiss: {
                selectedBlock = nil
            }, content: { block in
                SubLogSheet(block: block, version: version, onSave: { subLog in
                })
            })
        }
    }
}


extension AnyTransition {
    static var moveAndFade: AnyTransition {
        AnyTransition.move(edge: .trailing)
    }
}
