//
//  AudioBlock.swift
//  Logbook
//
//  Created by Tan Yun ching on 6/3/22.
//

import Foundation
import FirebaseFirestoreSwift

struct AudioBlock: Codable {
    var id: String? = UUID().uuidString
    var path: URL
    var startTime: Date
    var duration: Double
}
