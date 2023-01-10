//
//  LetSeeConfigurationKey.swift
//  
//
//  Created by Farshad Jahanmanesh on 06/01/2023.
//

import LetSee
import SwiftUI
extension EnvironmentValues {
    var letSeeConfiguration: LetSee.Configuration {
        set {
            self[LetSeeConfigurationKey.self] = newValue
        }
        get {
            self[LetSeeConfigurationKey.self]
        }
    }
}

struct LetSeeConfigurationKey: EnvironmentKey {
    static let defaultValue: LetSee.Configuration = LetSee.shared.configuration
}
