//
//  LetSee+URLProtocol.swift
//  
//
//  Created by Farshad Macbook M1 Pro on 5/1/22.
//

import Foundation
public final class LetSeeURLProtocol: URLProtocol {
	public static unowned var letSee: LetSee!
	public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
		request
	}
	
	public override class func canInit(with request: URLRequest) -> Bool {
		true
	}

	public override func startLoading() {
		let client = self.client
		Self.letSee.updateResult(request: self.request, cb: { result in
			switch result {
			case .success(let data):
				client?.urlProtocol(self, didLoad: data)
			case .failure(let error):
				client?.urlProtocol(self, didFailWithError: error)
			}
			client?.urlProtocolDidFinishLoading(self)
		})
	}

	public override func stopLoading() {
		Self.letSee.remove(request: self.request)
	}
}

public protocol LetSeeMockProviding {
	static var mocks:[LetSeeMock] {get}
}

public enum LetSeeMock: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(data)
		hasher.combine(name)
	}
	public var hashValue: Int {
		var hasher = Hasher()
		self.hash(into: &hasher)
		return hasher.finalize()
	}
	case failure(name: String, data: JSON)
	case success(name: String, data: JSON)
	var data: Data? {
		self.string?.data(using: .utf8)
	}

	var name: String {
		switch self {
		case .failure(let name,_):
			return name
		case .success(let name, _):
			return name
		}
	}

	var string: String? {
		let result: JSON
		switch self {
		case .failure(_, let jSON):
			result = jSON
		case .success(_, let jSON):
			result = jSON
		}
		return result
			.replacingOccurrences(of: "\n", with: "")
			.replacingOccurrences(of: "\'", with: "\"")
	}

	var formatted: String? {
		let data = self.data
		guard let data = data else {
			return nil
		}

		do {
			let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
			let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
			guard let jsonString = String(data: jsonData, encoding: .utf8) else {
				return nil
			}
			return jsonString
		} catch {
			return nil
		}
	}
}

public struct Me {
	public let name: String
	public let family: String
	public init(
		name: String,
		family: String) {
			self.name = name
			self.family = family

		}
}

extension Me: LetSeeMockProviding {
	public static var mocks: [LetSeeMock] {
		[
			.success(name: "Normal User", data:
"""
{
 'name':'Farshad',
 'family': 'Jahanmanesh'
}
"""
					),

				.failure(name: "User Not Found", data:
"""
{
 'message':'User not found.'
}
"""
						),

				.failure(name: "User is Not Active", data:
"""
{
 'message':'User is Not Active.'
   }
"""
						),

				.success(name: "Admin User", data:
"""
{
  'name':'Farshad',
  'family': 'Jahanmanesh'
   }
"""
						),
		]
	}
}

