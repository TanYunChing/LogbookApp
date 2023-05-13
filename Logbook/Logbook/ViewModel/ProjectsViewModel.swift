//
//  ProjectsViewModel.swift
//  Logbook
//
//  Created by Tan Yun ching on 11/02/2022.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class ProjectsViewModel: ObservableObject {
    @Published var projects: [Project] = []
    
    @Published var showProgressView: Bool = false
    
    private var isFirstLoad = false
    
    // Initialize Firestore
    private let db = Firestore.firestore()
    
    init() {
        loadProjects()
    }
    
    private func loadProjects() {
        showProgressView = true
        db.collection(Project.collectionName).order(by: "createdAt", descending: true).addSnapshotListener { documentSnapshot, error in
            guard let documents = documentSnapshot?.documents else {
                print("Error fetching document: \(error!)")
                return
            }
            let list = documents.compactMap { doc -> Project? in
                try? doc.data(as: Project.self)
            }
            self.projects = list
            
            if !self.isFirstLoad {
                self.isFirstLoad = true
                DispatchQueue.main.async {
                    self.showProgressView = false
                }
            }
        }
    }
    
    func addProject(description: String, title: String, endDate: Date, onAdded: @escaping((Project) -> ())) {
        var project = Project(title: title, description: description, endDate: endDate)
        var ref: DocumentReference? = nil
        self.showProgressView = true
        ref = try? db.collection(Project.collectionName).addDocument(from: project) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                project.id = ref!.documentID
                
                DispatchQueue.main.async {
                    self.showProgressView = false
                    onAdded(project)
                }
            }
        }
    }
    
    func addOrUpdateLog(projectId: String, log: Log?) {
        if let updatedLog = log {
            if updatedLog.title.isEmpty && updatedLog.description.isEmpty && updatedLog.blocks.isEmpty {
                return
            }
            
            if let projectIndex = self.projects.firstIndex(where: { p in
                p.id == projectId
            }) {
                if let logIndex = self.projects[projectIndex].logs.firstIndex(where: { log in
                    log.id == updatedLog.id
                }) {
                    // update existing log
                    self.projects[projectIndex].logs[logIndex] = updatedLog
                    return
                }
                // append new log
                self.projects[projectIndex].logs.append(updatedLog)
            }
        }
        
    }
    
    func getDuration(createdAt: Date, endDate: Date) -> Double {
        let interval = DateInterval(start: createdAt, end: endDate)
        let duration = interval.duration
        let days = duration / (60*60*24)
        return days.rounded()
    }
    
    
    func getProgress(duration: Double, current: Date, endDate: Date) -> Double {
        
        if current < endDate {
        let elapsed = DateInterval(start: current, end: endDate).duration
        let elapsedDays = elapsed / (60*60*24)
        let progress = (elapsedDays / duration * 100).rounded() / 100
        return progress
        } else {
            let progress = 1.0
            return progress
        }
    }
    
    
}
