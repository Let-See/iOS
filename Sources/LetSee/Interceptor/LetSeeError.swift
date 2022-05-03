//
//  LetSeeError.swift
//  LetSee
//
//  Created by Farshad Macbook M1 Pro on 5/3/22.
//

import Foundation
public typealias LetSeeSuccessResponse = (response: URLResponse?, data: Data?)
public struct LetSeeError: Error {
	public var data: Data?
	public var error: Error
	public init(error: Error, data: Data?) {
		self.error = error
		self.data = data
	}

	public init(error: URLError.Code, data: Data?) {
		self.error = NSError(domain: NSURLErrorDomain, code: error.rawValue)
		self.data = data
	}

	public var localizedDescription: String {
		error.localizedDescription
	}
}
