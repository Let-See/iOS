//
//  LetSee+Interceptor+Extension.swift
//  
//
//  Created by Farshad Jahanmanesh on 07/01/2023.
//

import Foundation

/// Extension methods for `LetSee` class to provide session configuration and add `LetSeeURLProtocol` to a given configuration
public extension LetSee {
    /// Creates and returns a new ephemeral `URLSessionConfiguration` object with `LetSeeURLProtocol` as one of its `protocolClasses`.
    var sessionConfiguration: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.ephemeral
        LetSeeURLProtocol.letSee = self.interceptor
        configuration.timeoutIntervalForRequest = 3600
        configuration.timeoutIntervalForResource = 3600
        configuration.protocolClasses = [LetSeeURLProtocol.self]
        return configuration
    }

    /// Adds `LetSeeURLProtocol` as one of the `protocolClasses` of the given `URLSessionConfiguration` object.
    /// - Parameter config: The `URLSessionConfiguration` object to modify.
    /// - Returns: The modified `URLSessionConfiguration` object.
    func addLetSeeProtocol(to config : URLSessionConfiguration) -> URLSessionConfiguration {
        LetSeeURLProtocol.letSee = self.interceptor
        config.protocolClasses = [LetSeeURLProtocol.self] + (config.protocolClasses ?? [])
        return config
    }
}

/// Extension methods for `LetSee` class to conform to the `InterceptorContainer` protocol.
extension LetSee: InterceptorContainer {}
