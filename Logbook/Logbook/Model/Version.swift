//
//  Version.swift
//  Logbook
//
//  Created by Tan Yun ching on 16/4/22.
//

import Foundation
import FirebaseFirestoreSwift

struct Version: Codable, Identifiable {
    @DocumentID var id: String? = UUID().uuidString
    var count: Int = 1
    var description: String = ""
    var projectId: String
    var createdAt: Date = Date.now
    
    var formattedDate: String {
        DateFormatter.toPretty(createdAt)
    }
    
    var formattedVersion: String {
        "Version \(String(format:"%.1f", Float(count)))"
    }
}
