//
//  BlockModel.swift
//  Logbook
//
//  Created by Tan Yun ching on 6/3/22.
//

import Foundation
import FirebaseFirestoreSwift
import UIKit

struct BlockModel: Identifiable, Codable {
    @DocumentID var id: String? = UUID().uuidString
    var logId: String = UUID().uuidString
    var rootLogId: String = UUID().uuidString
    var createdAt: Date = Date.now
    var content: String = ""
    var audioBlock: AudioBlock?
    var imageBlock: UIImage?
    var imageUrl: URL?
    var fileUrl: URL?
    var logBlock: Log?
    var blockType: BlockType = .text
    var level: Int = 1

    var datePublished: String {
        DateFormatter.toPretty(createdAt)
    }
    
    // Omit imageBlock as it can't be serialized
    private enum CodingKeys: String, CodingKey {
        case id, logId, rootLogId, createdAt, content, audioBlock, imageUrl, fileUrl, blockType, logBlock, level
    }
}
