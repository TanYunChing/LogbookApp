//
//  project.swift
//  Logbook
//
//  Created by Tan Yun ching on 26/01/2022.
//

import Foundation
import FirebaseFirestoreSwift

struct Project: Identifiable, Codable {
    
    static let collectionName = "projects"
    
    @DocumentID var id: String? = UUID().uuidString
    var title: String = ""
    var description: String = ""
    var logs: [Log] = []
    var createdAt: Date = Date.now
    var endDate: Date = Date()

    var datePublished: String {
        DateFormatter.toPretty(createdAt)
    }
    
    // We only sending these attributes to be serialized
    private enum CodingKeys: String, CodingKey {
        case id, title, description, createdAt, endDate
    }
}



