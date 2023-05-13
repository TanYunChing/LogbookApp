//
//  DateFormatter.swift
//  Logbook
//
//  Created by Tan Yun ching on 6/3/22.
//

import Foundation

extension DateFormatter {
    static var datePublished: String = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        return dateFormatter.string(from: Date())
    }()
    
    static func toPretty(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

//        dateFormatter.dateFormat = "dd MMM yyyy"
        
        return dateFormatter.string(from: date)
    }
}
