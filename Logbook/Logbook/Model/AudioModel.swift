//
//  AudioModel.swift
//  Logbook
//
//  Created by Tan Yun ching on 26/02/2022.
//

import Foundation
import AVFoundation

class AudioModel: NSObject, ObservableObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate{
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVPlayer?
    @Published var startTime: Date = Date()
    @Published var isRecording = false
    @Published var isRecorded = false
    @Published var isPlaying = false
    @Published var audioFileURL: URL?
    @Published var audios: AudioBlock?
    @Published var filename: String = "record"
    var fileCount: Int = 0
    var filePath: URL?
    
    private var timer = Timer
        .publish(every: 0.5, on: .main, in: .common)
        .autoconnect()
   
    // MARK: - Configuration
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func fileUrl() -> URL {
        let timestamp = Int(Date().timeIntervalSince1970)
        let filename = "\(self.filename)\(timestamp).m4a"
        print("new file named: ",filename)
        let path = getDocumentsDirectory().appendingPathComponent(filename)
        filePath = path
        return filePath!
    }
    
    
    func configureAudioSession() {
        let recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.record, mode: .spokenAudio)
            try recordingSession.setActive(true)
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            audioRecorder = try AVAudioRecorder(url: fileUrl(), settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.prepareToRecord()
          
        } catch {
            print("Fail to set audio session and audio recorder", error)
        }
    }
    
    func configurePlayer() {
        print("start player configuration")
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            if let url = filePath {
                if url.isFileURL {
                    let item = AVPlayerItem(url: url)
                    audioPlayer = AVPlayer(playerItem: item)
                } else {
                    let item = AVPlayerItem(url: url)
                    audioPlayer = AVPlayer(playerItem: item)
                }
                audioPlayer?.volume = 50.0
            }
        } catch {
            print("Fail to initialize player", error)
        }
    }
    
    //MARK: - User Action
    func recordTapped() {
        if let audioPlayer = audioPlayer {
            if audioPlayer.timeControlStatus == .playing {
                audioPlayer.pause()
                isPlaying = false
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(donePlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: audioPlayer?.currentItem)
       
        if audioRecorder == nil {
            configureAudioSession()
            audioRecorder?.record()
            startTime = Date()
            isRecording = true
            isRecorded = false
            print("Start recording at \(startTime)")
        } else {
            audioRecorder?.stop()
            audioFileURL = audioRecorder?.url
            audioRecorder = nil
            isRecording = false
            isRecorded = true
            print("End recording in \(String(describing: filePath))")
        }
    }
    
    func playTapped() {
        if audioPlayer == nil {
            self.configurePlayer()
        }

        guard let audioPlayer = audioPlayer else {return}
        if audioPlayer.timeControlStatus != .paused {
            audioPlayer.pause()
            isPlaying = false
            print("Stop playing")
            
        } else {
            if audioPlayer.currentTime() == audioPlayer.currentItem?.duration {
                audioPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
            }
            audioPlayer.play()
            isPlaying = true
            print("Start playing")
        }
    }
    
    
    func saveTapped() -> AudioBlock? {
        guard let audioPlayer = audioPlayer else {
            return nil
        }
        
        let newAudio = AudioBlock(path: filePath!, startTime: startTime, duration: audioPlayer.currentItem?.duration.seconds ?? 0)
        print(newAudio.path)
        print(newAudio.duration)
        audios = newAudio
        
        // reset variables
        isRecording = false
        isPlaying = false
        isRecorded = false
        return newAudio
    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            configurePlayer()
        }
    }
    
    @objc func donePlaying() {
        print("player stop playing")
        isPlaying = false
    }
}
