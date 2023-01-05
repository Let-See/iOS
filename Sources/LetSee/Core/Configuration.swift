//
//  Configuration.swift
//  
//
//  Created by Farshad Jahanmanesh on 05/01/2023.
//

import Foundation
public extension LetSee {
    struct Configuration: Equatable {
        public var isMockEnabled: Bool
        public var shouldCutBaseURLFromURLsTitle: Bool
        public var baseURL: String? = nil
        public init(isMockEnabled: Bool, shouldCutBaseURLFromURLsTitle: Bool, baseURL: String? = nil) {
            self.isMockEnabled = isMockEnabled
            self.shouldCutBaseURLFromURLsTitle = shouldCutBaseURLFromURLsTitle
            self.baseURL = baseURL
        }
    }
}

public extension LetSee.Configuration {
    static var `default`: Self {
        .init(isMockEnabled: false, shouldCutBaseURLFromURLsTitle: false)
    }
}
