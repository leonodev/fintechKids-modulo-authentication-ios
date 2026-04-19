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
    public func toDomain(pinApprove: String) -> FHKUserSession {
        return FHKUserSession(
            id: self.user.id,
            email: self.user.email ?? "",
            accessToken: self.accessToken,
            refreshToken: self.refreshToken,
            expiresAt: Date(timeIntervalSince1970: TimeInterval(self.expiresAt)),
            pinApproved: pinApprove
        )
    }
}


extension AuthResponse {
    func toDomain(pinApprove: String) -> FHKUserSession {
        switch self {
        case .session(let session):
            return FHKUserSession(
                id: session.user.id,
                email: session.user.email ?? "",
                accessToken: session.accessToken,
                refreshToken: session.refreshToken,
                pinApproved: pinApprove
            )
        case .user(let user):
            return FHKUserSession(
                id: user.id,
                email: user.email ?? "",
                accessToken: nil,
                refreshToken: nil,
                pinApproved: pinApprove
            )
        }
    }
}
