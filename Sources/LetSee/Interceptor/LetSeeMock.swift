//
//  LetSeeMock.swift
//  LetSee
//
//  Created by Farshad Macbook M1 Pro on 5/3/22.
//

import Foundation
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
	case failure(name: String, response: URLError.Code, data: JSON)
	case success(name: String, response: LetSeeMockResponse? , data: JSON)
	case error(name: String, URLError)
	case live
	case cancel
	var data: Data? {
		self.string?.data(using: .utf8)
	}

	var name: String {
		switch self {
		case .failure(let name, _, _):
			return name
		case .success(let name, _, _):
			return name
		case .error(let name, _):
			return name
		case .live:
			return "Live"
		case .cancel:
			return "Cancel"
		}
	}

	var string: String? {
		let result: JSON
		switch self {
		case .failure(_, _, let jSON):
			result = jSON
		case .success(_, _, let jSON):
			result = jSON
		case .error(_, let error):
			result = error.localizedDescription
		case .live, .cancel:
			return nil
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

public extension LetSeeMock {
	static func defaultSuccess(name: String, data: JSON) -> LetSeeMock {
		let response = LetSeeMockResponse(stateCode: 200, header: ["Content-Type": "application/json"])
		return .success(name: name, response: response, data: data)
	}

	static func defaultFailure(name: String, data: JSON) -> LetSeeMock {
		let response = LetSeeMockResponse(stateCode: 400, header: ["Content-Type": "application/json"])
		return .success(name: name, response: response, data: data)
	}
}
