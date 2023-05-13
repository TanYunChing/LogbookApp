//
//  SequenceExtension.swift
//  Logbook
//
//  Created by Tan Yun ching on 12/3/22.
//

import Foundation

extension Sequence {
    func asyncForEach(
        _ operation: (Element) async throws -> Void
    ) async rethrows {
        for element in self {
            try await operation(element)
        }
    }
    
    func asyncForEachIndexed(
        _ operation: (Int, Element) async throws -> Void
    ) async rethrows {
        for (index, element) in self.enumerated() {
            try await operation(index, element)
        }
    }
    
    func forEachIndexed(
        _ operation: (Int, Element) throws -> Void
    ) rethrows {
        for (index, element) in self.enumerated() {
            try operation(index, element)
        }
    }
    
    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()
        
        for element in self {
            try await values.append(transform(element))
        }
        
        return values
    }
    
    func concurrentMap<T>(
        _ transform: @escaping (Element) async throws -> T
    ) async throws -> [T] {
        let tasks = map { element in
            Task {
                try await transform(element)
            }
        }
        
        return try await tasks.asyncMap { task in
            try await task.value
        }
    }
}
