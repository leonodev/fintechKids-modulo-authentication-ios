//
//  DependenciesInjection+Extension.swift
//  FHKAuth
//
//  Created by Fredy Leon on 21/2/26.
//

import FHKInjections
import FHKDomain

public extension DependenciesInjection {
    
    var servicesAPI: any ServicesAPIProtocol {
        get { self[(any ServicesAPIProtocol).self] }
        set { self[(any ServicesAPIProtocol).self] = newValue }
    }
    
    var languageManager: any FHKLanguageManagerProtocol {
        get { self[(any FHKLanguageManagerProtocol).self] }
        set { self[(any FHKLanguageManagerProtocol).self] = newValue }
    }
    
    var storageManager: any FHKStorageManagerProtocol {
        get { self[(any FHKStorageManagerProtocol).self] }
        set { self[(any FHKStorageManagerProtocol).self] = newValue }
    }
    
    var configManager: any FHKConfigurationProtocol {
        get { self[(any FHKConfigurationProtocol).self] }
        set { self[(any FHKConfigurationProtocol).self] = newValue }
    }
}
