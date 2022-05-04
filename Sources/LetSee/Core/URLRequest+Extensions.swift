//
//  URLRequest+Extensions.swift
//  
//
//  Created by Farshad Macbook M1 Pro on 4/24/22.
//

import Foundation

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

