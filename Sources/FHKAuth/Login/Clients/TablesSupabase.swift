//
//  TablesSupabase.swift
//  FHKAuth
//
//  Created by Fredy Leon on 10/3/26.
//

public struct DB {
    
    public struct TABLE_FAMILIES {
        public static let NAME: String = "fhk_families"
        
        public struct COLUMN {
            public static let createdAt = "created_at"
            public static let nameFamily = "name_family"
            public static let emailParent = "email_parent"
            public static let approvePin = "approve_pin"
        }
    }
}
