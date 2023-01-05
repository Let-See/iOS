//
//  LetSeeMock.swift
//  LetSee
//
//  Created by Farshad Macbook M1 Pro on 5/3/22.
//

import Foundation
public typealias JSON = String
public extension LetSeeMock {
    enum Category: Int {
        case general = 0
        case specific
        case suggested
        public var name: String {
            switch self {
            case .general: return "General"
            case .specific: return "Specific"
            case .suggested: return "Suggested"
            }
        }
    }
}
public enum LetSeeMock: Hashable, Comparable {
	public static func < (lhs: LetSeeMock, rhs: LetSeeMock) -> Bool {
		switch (lhs, rhs) {
		case (_, .live):
			return true
		case (.live, _):
			return false
		case (_, .cancel):
			return true
		case (.cancel, _):
			return false
		case (.success, _):
			return true
		case (_, .success):
			return false
		case (.failure, .error):
			return true
		default: return true
		}
	}

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

	public var name: String {
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

	public var string: String? {
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

	public var formatted: String? {
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

	public func mapJson(_ json: JSON) -> LetSeeMock {
		switch self {
		case .failure(let name, let response, _):
			return .failure(name: name, response: response, data: json)
		case .success(let name, let response, _):
			return .success(name: name, response: response, data: json)
		case .error, .live, .cancel:
			return self
		}
	}
}

public extension LetSeeMock {
	static func defaultSuccess(name: String, data: JSON) -> LetSeeMock {
		let response = LetSeeMockResponse(stateCode: 200, header: ["Content-Type": "application/json"])
		return .success(name: name, response: response, data: data)
	}

	static func defaultFailure(name: String, data: JSON) -> LetSeeMock {
		return .failure(name: name, response: .badServerResponse, data: data)
	}
}
