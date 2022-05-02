//
//  URLRequest+Extensions.swift
//  
//
//  Created by Farshad Macbook M1 Pro on 4/24/22.
//

import Foundation


protocol LetSeeRequest: AnyObject {
	var request: URLRequest{get}
	var mocks: [LetSeeMock]{get set}
	var id: String {get set}
}

extension LetSeeRequest {
	func makeIdentifiable() -> Self {
		self.id = UUID().uuidString
		return self
	}

//	func attachMocks(_ mockProvider: LetSeeMockProviding) -> Self {
//		self.mocks = mockProvider.mocks
//		return self
//	}
}

public extension URLRequest {
	func addLetSeeID() -> URLRequest {
		guard self.letSeeId == nil else {return self}
		var request = self
		request.letSeeId = UUID().uuidString
		return request
	}

	var letSeeId: String? {
		get{
			guard let id = self.allHTTPHeaderFields?.first(where: {$0.key == LetSee.headerKey}) else {
				return nil
			}
			return id.value
		}

		set {
			if let newValue = newValue {
				self.addValue(newValue, forHTTPHeaderField: LetSee.headerKey)
			} else {
				self.allHTTPHeaderFields?.removeValue(forKey: LetSee.headerKey)
			}
		}
	}
}

