//
//  Configuration.swift
//  
//
//  Created by Farshad Jahanmanesh on 05/01/2023.
//

import Foundation
public extension LetSee {
    /// The `Configuration` struct represents the configuration for the `LetSee` instance.
    ///
    /// - isMockEnabled: A boolean value that determines whether mock data is enabled or not. If `true`, mock data will be used to respond to requests. If `false`, requests will be sent to the server.
    /// - shouldCutBaseURLFromURLsTitle: A boolean value that determines whether the base URL should be removed from the title of the request.
    /// - baseURL: An optional string that represents the base URL that should be used for requests.
    struct Configuration: Equatable {
        public var isMockEnabled: Bool
        public var shouldCutBaseURLFromURLsTitle: Bool
        public var baseURL: String? = nil

        /// Initializes a new `Configuration` instance.
        ///
        /// - Parameters:
        ///   - isMockEnabled: A boolean value that determines whether mock data is enabled or not. If `true`, mock data will be used to respond to requests. If `false`, requests will be sent to the server.
        ///   - shouldCutBaseURLFromURLsTitle: A boolean value that determines whether the base URL should be removed from the title of the request.
        ///   - baseURL: An optional string that represents the base URL that should be used for requests.
        public init(isMockEnabled: Bool, shouldCutBaseURLFromURLsTitle: Bool, baseURL: String? = nil) {
            self.isMockEnabled = isMockEnabled
            self.shouldCutBaseURLFromURLsTitle = shouldCutBaseURLFromURLsTitle
            self.baseURL = baseURL
        }
    }
}

public extension LetSee.Configuration {
    /// A default `Configuration` instance that has `isMockEnabled` set to `false` and `shouldCutBaseURLFromURLsTitle` set to `false`.
    static var `default`: Self {
        .init(isMockEnabled: false, shouldCutBaseURLFromURLsTitle: false)
    }
}
