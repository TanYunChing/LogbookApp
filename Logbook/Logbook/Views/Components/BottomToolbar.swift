//
//  BottomToolbar.swift
//  Logbook
//
//  Created by Tan Yun ching on 8/3/22.
//

import SwiftUI

struct BottomToolbar: View {
    
    @EnvironmentObject var blockVM: LogsViewModel
    
    //Sub-components
    let version: Version
    
    // Audio related
    var audioModel: AudioModel
    @State var showAudioBar = false
    @State private var elapsed: Double = 0.0
    
    // Image
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var inputImage: UIImage?
    
    // File
    @State private var showDocumentPicker = false
    @State private var document: URL?
    
    // Text
    @State private var message = ""
    
    
    let timer = Timer
        .publish(every: 0.4, on: .main, in: .common)
        .autoconnect()
    
    var body: some View {
        ZStack {
            if showAudioBar {
                // Audio controls
                HStack {
                    //Keyboard
                    CustomButton(systemName: "keyboard.fill", color: .white) {
                        showAudioBar.toggle()
                    }
                    
                    HStack {
                        //Record Button
                        CustomButton(systemName: audioModel.isRecording ? "pause.circle.fill" : "mic.circle.fill", color: audioModel.isPlaying ? .white.opacity(0.2) : .white.opacity(1)) {
                            hideKeyboard()
                            audioModel.recordTapped()
                        }.disabled(audioModel.isPlaying)
                        
                        //Play Button
                        if audioModel.isRecorded == true {
                            CustomButton(systemName: audioModel.isPlaying ? "pause.circle.fill" : "play.circle.fill", color: .white) {
                                hideKeyboard()
                                audioModel.playTapped()
                            }
                            
                            Spacer()
                            
                            if audioModel.isPlaying {
                                // Text(DateComponentsFormatter.positional.string(from: value) ?? "0:00")
                            } else {
                                // Save Button
                                Button {
                                    hideKeyboard()
                                    let audioBlock = self.audioModel.saveTapped()
                                    self.blockVM.addBlock(audioBlock: audioBlock)
                                } label: {
                                    Text("Save")
                                        .font(.caption)
                                        .bold()
                                        .opacity(audioModel.isPlaying ? 0.2 : 1)
                                }
                                .disabled(audioModel.isPlaying)
                                .padding(.trailing)
                            }
                            
                        } else {
                            Spacer()
                            
                            if audioModel.isRecording {
                                Text(audioModel.startTime, style: .timer)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.trailing)
                            } else {
                                Text("0:00")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.trailing)
                                
                            }
                        }
                    }
                    .onReceive(timer) {_ in
                        elapsed += 1
                        guard let audioPlayer = audioModel.audioPlayer else { return }
                    }
                    .frame(maxWidth: .infinity, minHeight: 35, maxHeight: 35)
                    .background(.ultraThinMaterial)
                    .cornerRadius(6)
                    .padding([.top, .trailing, .bottom])
                }
                .frame(maxWidth: .infinity, minHeight: 55, maxHeight: 55)
            } else {
                // Normal controls
                HStack(alignment: .center) {
                    Menu {
                        CustomButton(systemName: "square.grid.2x2", label: "Add Component", fontSize: 16) {
                            hideKeyboard()
                            let log = Log(versionId: version.id!, level: ((blockVM.log?.level)! + 1))
                            saveLogBlock(log: log)
                        }
                        
//                        CustomButton(systemName: "number", label: "Tag", fontSize: 16) {
//                            hideKeyboard()
//                            let log = Log(versionId: version.id!, level: 0)
//                            saveLogBlock(log: log)
//                        }
                        
                    } label: {
                        Label("", systemImage: "plus")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                    
                    //menuButton
                    Menu {
                        VStack {
                            //Button 1
                            CustomButton(systemName: "camera", label: "Take Photo or Video") {
                                hideKeyboard()
                                showingCamera = true
                            }
                            
                            //Button 2
                            CustomButton(systemName: "photo.on.rectangle", label: "Choose Photo or Video") {
                                hideKeyboard()
                                showingImagePicker = true
                            }
                            
                            //Button 3
                            CustomButton(systemName: "doc", label: "Upload Document") {
                                hideKeyboard()
                                showDocumentPicker = true
                            }
                            
                            //Button 4
                            CustomButton(systemName: "mic", label: "Record Voice") {
                                hideKeyboard()
                                showAudioBar = true
                            }
                        }
                    } label: {
                        Label("", systemImage: "camera")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                    
                    TextField("Type Something", text: $message)
                        .font(.callout)
                        .padding(.all, 5)
                        .background(.thinMaterial)
                        .cornerRadius(6)
                    
                    CustomButton(systemName: "paperplane.fill", fontSize: 16) {
                        hideKeyboard()
                        saveText()
                    }
                }
                .sheet(isPresented: $showDocumentPicker) {
                    DocumentPicker(document: $document)
                }
                .onChange(of: document, perform: chooseDocument)
                .sheet(isPresented: $showingImagePicker, onDismiss: chooseImage) {
                    ImagePicker(image: $inputImage)}
                .fullScreenCover(isPresented: $showingCamera, onDismiss: chooseImage) {
                    ImagePicker(sourceType:.camera, image: $inputImage)
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 15)
                .frame(maxWidth: .infinity, minHeight: 55, maxHeight: 55)
                .background(.clear, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
            }
        }
        .foregroundColor(.primary)
        .frame(maxWidth: .infinity, minHeight: 55, maxHeight: 55)
        
    }
    fileprivate func saveLogBlock(log: Log) {
        blockVM.addBlock(log: log)
    }
    
    
    fileprivate func saveText() {
        blockVM.addBlock(text: message)
        message = ""
    }
    
    fileprivate func chooseImage() {
        blockVM.addBlock(image: inputImage)
        showingImagePicker = false
        showingCamera = false
        inputImage = nil
    }
    
    fileprivate func chooseDocument(doc: URL?) {
        blockVM.addBlock(url: doc)
        document = nil
    }
}
