//
//  SessionToUserSession.swift
//  FHKAuth
//
//  Created by Fredy Leon on 27/2/26.
//

import Foundation
import Supabase
import FHKDomain

public extension Session {
    public func toDomain() -> FHKUserSession {
        return FHKUserSession(
            id: self.user.id,
            email: self.user.email ?? "",
            accessToken: self.accessToken,
            refreshToken: self.refreshToken,
            expiresAt: Date(timeIntervalSince1970: TimeInterval(self.expiresAt))
        )
    }
}


extension AuthResponse {
    func toDomain() -> FHKUserSession {
        switch self {
        case .session(let session):
            return FHKUserSession(
                id: session.user.id,
                email: session.user.email ?? "",
                accessToken: session.accessToken,
                refreshToken: session.refreshToken
            )
        case .user(let user):
            return FHKUserSession(
                id: user.id,
                email: user.email ?? "",
                accessToken: nil,
                refreshToken: nil
            )
        }
    }
}
