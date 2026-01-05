//
//  JailbreakManager.swift
//  FHKAuth
//
//  Created by Fredy Leon on 5/1/26.
//

import UIKit

public protocol JailbreakManagerProtocol {
    var isDeviceCompromised: Bool { get }
}

public final class SecurityManager: JailbreakManagerProtocol, @unchecked Sendable {
    
    public static let shared = SecurityManager()
    
    // El Lock garantiza que si varios hilos preguntan a la vez,
    // no haya condiciones de carrera (Race Conditions).
    private let lock = NSLock()
    
    private init() {}
    
    public var isDeviceCompromised: Bool {
        lock.lock()
        // Nos aseguramos de liberar el lock pase lo que pase al terminar la función
        defer { lock.unlock() }
        
        #if targetEnvironment(simulator)
        return false
        #else
        return checkSuspiciousFiles() ||
               checkSystemPaths() ||
               checkCydiaCanBeOpened() ||
               canForkProcess()
        #endif
    }
    
    // MARK: - Métodos Privados
    
    private func checkSuspiciousFiles() -> Bool {
        let paths = [
            "/Applications/Cydia.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/private/var/lib/apt/"
        ]
        return paths.contains { FileManager.default.fileExists(atPath: $0) }
    }

    private func checkSystemPaths() -> Bool {
        let path = "/private/jailbreak_test.txt"
        do {
            try "test".write(toFile: path, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: path)
            return true
        } catch {
            return false
        }
    }

    private func checkCydiaCanBeOpened() -> Bool {
        // Importante: Esto requiere LSApplicationQueriesSchemes en Info.plist
        guard let url = URL(string: "cydia://package/com.example.package") else { return false }
        return UIApplication.shared.canOpenURL(url)
    }

    private func canForkProcess() -> Bool {
        typealias ForkFunction = @convention(c) () -> Int32
        
        let handle = dlopen(nil, RTLD_NOW)
        if let symbol = dlsym(handle, "fork") {
            let fork = unsafeBitCast(symbol, to: ForkFunction.self)
            let pid = fork()
            
            if pid >= 0 {
                if pid > 0 {
                    kill(pid, SIGTERM)
                }
                return true
            }
        }
        return false
    }
}
