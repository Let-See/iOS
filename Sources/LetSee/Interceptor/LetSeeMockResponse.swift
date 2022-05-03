//
//  LetSeeMockResponse.swift
//  LetSee
//
//  Created by Farshad Macbook M1 Pro on 5/3/22.
//

import Foundation
public struct LetSeeMockResponse: Hashable {
	public let stateCode: Int
	public let header: [String: String]
	public init(
		stateCode: Int,
		header: [String: String]
	) {
		self.stateCode = stateCode
		self.header = header
	}
}

public extension LetSeeMockResponse {
	var asURLResponse: URLResponse {
		HTTPURLResponse(url: URL(string: "www.letsee.com")!, statusCode: self.stateCode, httpVersion: nil, headerFields: self.header)!
	}
}
