//
//  Log.swift
//  Logbook
//
//  Created by Tan Yun ching on 6/3/22.
//

import Foundation
import FirebaseFirestoreSwift

struct Log: Identifiable, Codable {
    
    static let collectionName = "logs"
    
    @DocumentID var id: String? = UUID().uuidString
    var projectId: String? = UUID().uuidString
    var versionId: String
    var title: String = ""
    var description: String = ""
    var createdAt: Date = Date.now
    var blocks: [BlockModel] = []
    var level: Int = 1

    var datePublished: String {
        DateFormatter.toPretty(createdAt)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, projectId, versionId, title, description, createdAt, level
    }
}
