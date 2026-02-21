//
//  FHKAuthDemoApp.swift
//  FHKAuthDemo
//
//  Created by Fredy Leon on 15/11/25.
//

import SwiftUI
import FHKInjections
import FHKCore

@main
struct FHKAuthDemoApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    Dependencies.registerAll()
                }
        }
    }
}


public class Dependencies {
    static func registerAll() {
        let deps = DependenciesInjection.shared
        
        deps.set(ServicesAPI(), for: (any ServicesAPIProtocol).self)
    }
}
