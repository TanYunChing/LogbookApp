//
//  BlockViewModel.swift
//  Logbook
//
//  Created by Tan Yun ching on 05/03/2022.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseStorageSwift


class LogsViewModel: ObservableObject, Identifiable {
    @Published var log : Log?
    var rootLogId: String = UUID().uuidString
    
    @Published var showProgressView: Bool = false
    @Published var showComponentsView: Bool = false
    
    
    // MARK: Initialize Firestore
    private let db = Firestore.firestore()
    
    // MARK: Initialize Firebase Storage
    private let storage = Storage.storage()
    
    // MARK: Load sub component info
    func loadSubLog(blockId: String?) {
        showProgressView = true
        if let id = blockId, self.log == nil {
            Task {
                let dbLog = try? await db.collection("blocks").document(id)
                    .getDocument()
                
                DispatchQueue.main.sync {
                    self.log = try? dbLog?.data(as: BlockModel.self).logBlock ?? Log(versionId: "")
                    loadBlocks(isSubLog: true)
                }
            }
        } else {
            loadBlocks(isSubLog: true)
        }
    }
    
    // MARK: Load blocks
    func loadBlocks(isSubLog: Bool) {
        let id = self.log?.id
        self.showProgressView = true
        
        Task {
            db.collection("blocks")
                .whereField("logId", isEqualTo: id!)
                .order(by: "createdAt")
                .addSnapshotListener { documentSnapshot, error in
                    guard let documents = documentSnapshot?.documents else {
                        print("Error fetching document: \(error!)")
                        return
                    }
                    
                    let list = documents.compactMap { doc -> BlockModel? in
                        let block = try? doc.data(as: BlockModel.self)
                        // block?.rootLogId = self.log!.id!
                        return block
                    }
                    
                    DispatchQueue.main.async {
                        self.log?.blocks = list
                        self.showProgressView = false
                    }
                }
        }
    }
    
    // MARK: Add Components
    func addBlock(log: Log?) {
        if log == nil {
            return
        }
        
        Task {
            let block = BlockModel(logId: self.log!.id!, rootLogId: rootLogId, logBlock: log, blockType: .Log, level: self.log?.level ?? 0)
            
            try? db.collection("blocks").addDocument(from: block)
        }
    }
    
    // MARK: Update existing block
    func updateBlock(updatedBlock: BlockModel) {
        if let index = self.log?.blocks.firstIndex(where: { block in
            block.id == updatedBlock.id
        }) {
            self.log?.blocks[index] = updatedBlock
        }
    }
    
    // MARK: Add Text
    func addBlock(text: String?) {
        if text == nil || text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            return
        }
        
        let block = BlockModel(logId: self.log!.id!, rootLogId: rootLogId, content: text ?? "", blockType: .text, level: self.log?.level ?? 0)
        _ = try? db.collection("blocks").addDocument(from: block)
    }
    
    
    /// Add document
    /// - Parameter url: <#url description#>
    func addBlock(url: URL?) {
        if let url = url {
            Task {
                var block = BlockModel(logId: self.log!.id!, rootLogId: rootLogId, fileUrl: url, blockType: .File, level: self.log?.level ?? 0)
                let urlString = await uploadPDFFile(url: url)
                block.fileUrl = urlString
                _ = try? db.collection("blocks").addDocument(from: block)
            }
        }
    }
    
    /// Add image
    /// - Parameter image: <#image description#>
    func addBlock(image: UIImage?) {
        if image == nil {
            return
        }
        
        Task {
            var block = BlockModel(logId: self.log!.id!, rootLogId: rootLogId, imageBlock: image, blockType: .Image, level: self.log?.level ?? 0)
            
            let urlString = await uploadImage(image: image!)
            block.imageUrl = urlString
            _ = try? db.collection("blocks").addDocument(from: block)
        }
    }
    
    /// Add recorded audio
    /// - Parameter audioBlock: <#audioBlock description#>
    func addBlock(audioBlock: AudioBlock?) {
        if let audio = audioBlock {
            Task {
                var block = BlockModel(logId: self.log!.id!, rootLogId: rootLogId, audioBlock: audio, blockType: .Audio, level: self.log?.level ?? 0)
                let urlString = await uploadAudioFile(url: audio.path)
                block.fileUrl = urlString
                _ = try? db.collection("blocks").addDocument(from: block)
            }
        }
    }
    
    /// Remove block from log
    /// - Parameter block: <#block description#>
    func removeBlock(block: BlockModel?) {
        Task {
            if let block = block {
                _ = try? await db.collection("blocks").document(block.id!).delete()
            }
        }
    }
    
    /// Function to upload image file to Firebase Storage
    /// - Parameter image: UIImage
    /// - Returns: storage file path
    private func uploadImage(image: UIImage) async -> URL? {
        let timestamp = Int(Date().timeIntervalSince1970)
        
        // Create a storage reference
        let storageRef = storage.reference().child("images/\(timestamp).jpg")
        
        // Convert the image into JPEG and compress the quality to reduce its size
        let data = image.jpegData(compressionQuality: 0.34)
        
        // Change the content type to jpg. If you don't, it'll be saved as application/octet-stream type
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        // Upload the image
        if let data = data {
            _ = try? await storageRef.putDataAsync(data, metadata: metadata)
            return try? await storageRef.downloadURL()
        }
        return nil
    }
    
    /// Function to upload pdf to Firebase Storage
    /// - Parameter url: Local URL
    /// - Returns: storage file path
    private func uploadPDFFile(url: URL) async -> URL? {
        let timestamp = Int(Date().timeIntervalSince1970)
        
        // Create a storage reference
        let storageRef = storage.reference().child("pdf/\(timestamp).pdf")
        
        let metadata = StorageMetadata()
        metadata.contentType = "application/pdf"
        
        _ = try? await storageRef.putFileAsync(from: url, metadata: metadata)
        return try? await storageRef.downloadURL()
    }
    
    /// Function to upload pdf to Firebase Storage
    /// - Parameter url: Local URL
    /// - Returns: storage file path
    private func uploadAudioFile(url: URL) async -> URL? {
        let timestamp = Int(Date().timeIntervalSince1970)
        
        // Create a storage reference
        let storageRef = storage.reference().child("audio/\(timestamp).m4a")
        
        let metadata = StorageMetadata()
        metadata.contentType = "audio/m4a"
        
        _ = try? await storageRef.putFileAsync(from: url, metadata: metadata)
        return try? await storageRef.downloadURL()
    }
}
