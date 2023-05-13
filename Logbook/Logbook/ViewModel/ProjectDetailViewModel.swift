//
//  ProjectDetailViewModel.swift
//  Logbook
//
//  Created by Tan Yun ching on 10/3/22.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class ProjectDetailViewModel: ObservableObject {
    
    var version: Version? = nil
    
    @Published var showProgressView: Bool = false
    
    @Published var logs: [Log] = []
    private var logList: [Log] = []
    
    private var listener: ListenerRegistration? = nil
    
    // Initialize Firestore
    private nonisolated let db = Firestore.firestore()
    
    deinit {
        // MARK: Stop subscribing from Firestore
        listener?.remove()
        listener = nil
    }
    
    func setVersion(version: Version) {
        self.version = version
    }
    
    func loadLogs() {
        if listener == nil {
            // MARK: Fetch logs where projectId = current project Id
            if let version = version {
                showProgressView = true
                Task {
                    self.listener = self.db.collection(Log.collectionName)
                        .whereField("projectId", isEqualTo: version.projectId)
                        .whereField("versionId", isEqualTo: version.id!)
                        .order(by: "createdAt", descending: true)
                        .addSnapshotListener { documentSnapshot, error in
                            guard let documents = documentSnapshot?.documents else {
                                print("Error fetching document: \(error!)")
                                return
                            }
                            
                            let data = documents.compactMap { snapshot -> Log? in
                                try? snapshot.data(as: Log.self)
                            }
                            
                            self.logList = data
                            self.loadBlocks()
                        }
                }
            }
        }
    }
    
    func loadBlocks() {
        db.collection("blocks")
            .whereField("blockType", isEqualTo: "Log")
            .whereField("logBlock.level", in: [2, 3])
            .order(by: "createdAt")
            .addSnapshotListener { documentSnapshot, error in
                guard let documents = documentSnapshot?.documents else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                let blockModels = documents.compactMap { snapshot -> BlockModel? in
                    try? snapshot.data(as: BlockModel.self)
                }
                
                Task {
                    self.logs = self.logList.map { log in
                        var mutateLog = log
                        mutateLog.blocks.removeAll()
                        
                        blockModels.forEach { b in
                            if b.logId == log.id {
                                mutateLog.blocks.append(b)
                                
                                let subBlocks = blockModels.filter { i in
                                    return b.id == i.logId
                                }
                                mutateLog.blocks.append(contentsOf: subBlocks)
                            }
                        }
                        return mutateLog
                    }
                    
                    DispatchQueue.main.async {
                        self.showProgressView = false
                    }
                }
            }
    }
    
    func addSubLog(block: BlockModel, log: Log?, onAdded: @escaping((Log) -> ())) {
        self.showProgressView = true
        Task {
            if var newLog = log {
                if newLog.title.isEmpty && newLog.description.isEmpty && newLog.blocks.isEmpty {
                    return
                }
                
                let blockDocument = try? await db.collection("blocks").document(block.id!).getDocument()
                
                if blockDocument != nil {
                    try? await db.collection("blocks").document(block.id!).updateData([
                        "logBlock.title": newLog.title, "logBlock.description": newLog.description
                    ])
                } else {
                    newLog.level = block.level
                    var saveBlock = block
                    saveBlock.logBlock = newLog
                    _ = try? db.collection("blocks").addDocument(from: saveBlock)
                }
                
                DispatchQueue.main.async {
                    self.showProgressView = false
                }
                onAdded(newLog)
            }
        }
    }
    
    func commit(log: Log?, onAdded: @escaping((Log) -> ())) {
        Task {
            if let newLog = log {
                if newLog.title.isEmpty && newLog.description.isEmpty && newLog.blocks.isEmpty {
                    return
                }
                
                self.showProgressView = true
    
                try? db.collection(Log.collectionName).document(newLog.id!).setData(from: newLog)
                
                if newLog.level != 1 {
                    self.showProgressView = false
                    onAdded(newLog)
                    return
                }
                self.showProgressView = false
                onAdded(newLog)
            }
        }
    }
}
