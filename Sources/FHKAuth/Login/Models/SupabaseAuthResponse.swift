//
//  SupabaseAuthResponse.swift
//  FHKAuth
//
//  Created by Fredy Leon on 11/12/25.
//

import Foundation
import Supabase

public struct SupabaseAuthResponse: Decodable, Sendable {
    public let accessToken: String
    public let expiresIn: Double
    public let expiresAt: Double
    public let refreshToken: String
    
    public let userID: String
    public let email: String
    
    public init(session: Session) {
        self.accessToken = session.accessToken
        self.expiresIn = session.expiresIn
        self.expiresAt = session.expiresAt
        self.refreshToken = session.refreshToken
        
        self.userID = session.user.id.uuidString
        self.email = session.user.email ?? ""
    }
}
