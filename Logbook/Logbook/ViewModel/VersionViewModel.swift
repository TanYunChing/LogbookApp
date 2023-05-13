//
//  VersionViewModel.swift
//  Logbook
//
//  Created by Tan Yun ching on 16/4/22.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore

class VersionViewModel: ObservableObject {
    
    @Published var list: [Version] = []
    @Published var showProgressView: Bool = false
    
    // Initialize Firestore
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration? = nil
    
    deinit {
        DispatchQueue.global(qos: .userInitiated).async {
            // MARK: Stop subscribing from Firestore
            self.listener?.remove()
            self.listener = nil
        }
    }
    
    func fetchVersionList(projectId: String) {
        if listener != nil {
            return
        }
        
        self.showProgressView = true
        
        Task {
            listener = db.collection("versions")
                .whereField("projectId", isEqualTo: projectId)
                .order(by: "count", descending: true)
                .addSnapshotListener { [self] documentSnapshot, error in
                    guard let documents = documentSnapshot?.documents else {
                        print("Error fetching document: \(error!)")
                        return
                    }
                    
                    let list = documents.compactMap { doc -> Version? in
                        try? doc.data(as: Version.self)
                    }
                    
                    DispatchQueue.main.async {
                        self.list = list
                        self.showProgressView = false
                    }
                }
        }
    }
    
    func createVersion(projectId: String, description: String) {
        self.showProgressView = true
        Task {
            let docs = try? await db.collection("versions")
                .whereField("projectId", isEqualTo: projectId)
                .order(by: "count", descending: true)
                .limit(to: 1)
                .getDocuments()
            
            let latestVersion = docs?.documents.compactMap { item -> Version? in
                try? item.data(as: Version.self)
            }.first
            
            let latestVersionCode = latestVersion?.count ?? 0
            let id = db.collection("versions").document().documentID
            let newVersion = Version(id: id, count: (latestVersionCode + 1), description: description, projectId: projectId)
            let batch = db.batch()

            if let latestVersion = latestVersion {
                let logs = try? await db.collection(Log.collectionName)
                    .whereField("projectId", isEqualTo: projectId)
                    .whereField("versionId", isEqualTo: latestVersion.id!)
                    .getDocuments().documents
                
                await logs?.asyncForEach { logItem in
                    let logId = UUID().uuidString
                    var log = logItem.data()
                    log["versionId"] = newVersion.id
                    log.removeValue(forKey: "id")
                    batch.setData(log, forDocument: db.collection(Log.collectionName).document(logId))
                    
                    let blocks = try? await db.collection("blocks")
                        .whereField("rootLogId", isEqualTo: logItem.documentID)
                        .getDocuments().documents
                    
                    var blockList = blocks?.compactMap { snapshot -> BlockModel? in
                        try? snapshot.data(as: BlockModel.self)
                    } ?? []
                    
                    for index in blockList.indices {
                        let id = db.collection("blocks").document().documentID

                        blockList[index].rootLogId = logId

                        if blockList[index].level == 1 {
                            blockList[index].logId = logId
                        }
                        
                        let oldBlockId = blockList[index].id
                        blockList[index].id = id
                        
                        for i in blockList.indices {
                            if blockList[i].logId == oldBlockId {
                                blockList[i].logId = id
                            }
                        }
                    }
                    
                    try? blockList.forEachIndexed { index, block in
                        let doc = db.collection("blocks").document(block.id!)
                        try batch.setData(from: block, forDocument: doc)
                    }
                }
            }
            let versionDoc = db.collection("versions").document(newVersion.id!)
            _ = try? batch.setData(from: newVersion, forDocument: versionDoc)
            try? await batch.commit()
            
            DispatchQueue.main.async {
                self.showProgressView = false
            }
        }
    }
}
