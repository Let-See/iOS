//
//  LetSeeError.swift
//  LetSee
//
//  Created by Farshad Macbook M1 Pro on 5/3/22.
//

import Foundation
/**
This type alias represents a successful response to a request, consisting of a `URLResponse` and the associated data.
*/
public typealias LetSeeSuccessResponse = (response: URLResponse?, data: Data?)

/**
This struct represents an error in a request. It contains the error itself and any associated data.
*/
public struct LetSeeError: Error {
    /**
    The data associated with the error.
    */
    public var data: Data?

    /**
    The error.
    */
    public var error: Error

    /**
    Initializes the `LetSeeError` struct with an error and optional data.

    - Parameters:
        - error: The error.
        - data: The associated data.
    */
    public init(error: Error, data: Data?) {
        self.error = error
        self.data = data
    }

    /**
    Initializes the `LetSeeError` struct with a URL error code and optional data.

    - Parameters:
        - error: The URL error code.
        - data: The associated data.
    */
    public init(error: URLError.Code, data: Data?) {
        self.error = NSError(domain: NSURLErrorDomain, code: error.rawValue)
        self.data = data
    }

    /**
    A localized description of the error.
    */
    public var localizedDescription: String {
        error.localizedDescription
    }
}
