//
//  SupabaseApiError.swift
//  FHKAuth
//
//  Created by Fredy Leon on 12/1/26.
//

public struct SupabaseApiError: Decodable {
    let code: Int
    let errorCode: String
    let msg: String

    enum CodingKeys: String, CodingKey {
        case code
        case errorCode = "error_code"
        case msg
    }
}
