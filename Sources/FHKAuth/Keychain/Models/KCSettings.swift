//
//  KCSettings.swift
//  FHKAuth
//
//  Created by Fredy Leon on 21/11/25.
//

import Foundation

public struct KCSettings: Codable, Sendable {
    public var theme: String
    public var notifications: Bool
    
    public init() {
        self.theme = "light"
        self.notifications = true
    }
    
    public init(theme: String, notifications: Bool) {
        self.theme = theme
        self.notifications = notifications
    }
}
