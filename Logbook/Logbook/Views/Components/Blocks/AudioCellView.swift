//
//  AudioCellView.swift
//  Logbook
//
//  Created by Tan Yun ching on 01/03/2022.
//

import SwiftUI
import AVFoundation

// MARK: - Audio Cell View
struct AudioCellView: View {
    @EnvironmentObject var audioModel: AudioModel
    @State private var isEditing: Bool = false
    @State private var value: Double = 0.0
    var audioBlock: AudioBlock?
    var action: () -> Void
    
    @State private var timer = Timer
        .publish(every: 0.5, on: .main, in: .common)
        .autoconnect()
    
    var audioPlayer: AVPlayer? {
        audioModel.audioPlayer
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack {
                HStack {
                    // Play/ Pause Icon
                    CustomButton(systemName: (audioPlayer?.timeControlStatus == .playing) && (audioPlayer?.currentItem?.asset as? AVURLAsset)?.url == audioBlock?.path ? "pause.circle.fill" :  "play.circle.fill") {
                        
                        if audioModel.filePath != audioBlock?.path {
                            audioModel.filePath = audioBlock?.path
                            audioModel.configurePlayer()
                        }

                        withAnimation {
                            if audioPlayer?.timeControlStatus == .playing {
                                timer.upstream.connect().cancel()
                            } else {
                                timer = Timer
                                    .publish(every: 0.5, on: .main, in: .common)
                                    .autoconnect()
                            }
                            audioModel.playTapped()
                        }
                    }
                    
                    //Slider
                    Slider(value: $value, in: 0...(audioBlock?.duration ?? 0.0)) { editing in
                        print("editing", editing)
                        isEditing = editing

                        if !editing {
                            audioPlayer?.seek(to: CMTime(seconds: value, preferredTimescale: 1))
                        }
                    }
                    .frame(height: 10)
                    .accentColor(.white)
                    
                    // Timer
                    Text(DateComponentsFormatter.positional.string(from: value) ?? "0:00")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    
                }.onReceive(timer) {_ in
                    guard let audioPlayer = audioModel.audioPlayer, !isEditing else { return }
                    if (audioPlayer.currentItem?.asset as? AVURLAsset)?.url == audioBlock?.path {
                        value = audioPlayer.currentTime().seconds
                    } else {
                        timer.upstream.connect().cancel()
                    }
                }
            }
            .foregroundColor(.primary)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 40)
            .background(.ultraThinMaterial)
            .cornerRadius(6)
            .shadow(color: .secondary.opacity(0.4), radius: 2)
            
            Button(action: action) {
                HStack {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 6, height: 6)
                        .padding([.all], 6)
                        .foregroundColor(.white)
                        .background(.red)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
            }.offset(x: 6, y: -6)
        }
    }
    
}

