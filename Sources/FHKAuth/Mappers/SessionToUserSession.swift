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
    /// Mapea la Session de Supabase al modelo limpio de nuestro Dominio
    public func toDomain() -> FHKUserSession {
        return FHKUserSession(
            id: self.user.id,
            email: self.user.email ?? "",
            accessToken: self.accessToken,
            refreshToken: self.refreshToken,
            // Supabase usa Int para los segundos de expiración
            expiresAt: Date(timeIntervalSince1970: TimeInterval(self.expiresAt))
        )
    }
}


// En FHKAuth (Mapper)
extension AuthResponse {
    func toDomain() -> FHKUserSession {
        switch self {
        case .session(let session):
            // Tenemos todo: Usuario + Tokens
            return FHKUserSession(
                id: session.user.id,
                email: session.user.email ?? "",
                accessToken: session.accessToken,
                refreshToken: session.refreshToken
            )
        case .user(let user):
            // Solo tenemos el usuario (Registro pendiente de confirmación)
            return FHKUserSession(
                id: user.id,
                email: user.email ?? "",
                accessToken: nil,
                refreshToken: nil
            )
        }
    }
}
