//
//  DependenciesInjection+Extension.swift
//  FHKAuth
//
//  Created by Fredy Leon on 21/2/26.
//

import FHKInjections
import FHKConfig
import FHKCore

public extension DependenciesInjection {
    var servicesAPI: any ServicesAPIProtocol {
        get { self[(any ServicesAPIProtocol).self] }
        set { self[(any ServicesAPIProtocol).self] = newValue }
    }
}
