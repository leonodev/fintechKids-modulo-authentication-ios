//
//  KCError.swift
//  FHKAuth
//
//  Created by Fredy Leon on 21/11/25.
//
import Foundation

enum KCError: Error, Sendable {
    case notFound
    case duplicate
    case unexpected(OSStatus)
    
    static func from(status: OSStatus) -> Self {
        switch status {
        case errSecItemNotFound: .notFound
        case errSecDuplicateItem: .duplicate
        default: .unexpected(status)
        }
    }
}

extension KCError: CustomStringConvertible {
    var description: String {
        switch self {
        case .notFound: "Keychain item not found"
        case .duplicate: "Duplicate keychain item"
        case .unexpected(let status): "Keychain error: \(status)"
        }
    }
}
