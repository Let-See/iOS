//
//  LetSeeMock.swift
//  LetSee
//
//  Created by Farshad Macbook M1 Pro on 5/3/22.
//

import Foundation
public typealias JSON = String
public extension LetSeeMock {

    /**
     An enumeration of categories that LetSeeMock objects can belong to.

     The category of a LetSeeMock object is used to group similar mock objects together. There are three categories: general, specific, and suggested.

     - general: Mocks that can be used for any type of network request.
     - specific: Mocks that are tailored to specific types of network requests.
     - suggested: Mocks that are generated automatically by the LetSee framework based on real network requests.
     */
    enum Category: Int {
        case general = 0
        case specific
        case suggested

        /**
         The name of the category as a string.

         - Returns: The name of the category.
         */
        public var name: String {
            switch self {
            case .general: return "General"
            case .specific: return "Specific"
            case .suggested: return "Suggested"
            }
        }
    }
}


/// This enumeration represents a mock response that can be used to mock network requests in an iOS app. It has five cases:
///
/// **failure**: represents a mock response that represents a failed network request. It includes the name of the mock response, the response code for the request, and the data for the response.
///
/// **success**: represents a mock response that represents a successful network request. It includes the name of the mock response, the response code for the request, and the data for the response.
///
/// **error**: represents a mock response that represents a network request that resulted in an error. It includes the name of the mock response and the error that occurred.
///
/// **live**: represents a mock response that indicates that network requests should be sent live (i.e., not mocked).
///
/// **cancel**: represents a mock response that indicates that network requests should be cancelled.
///
/// The enumeration also includes several functions and properties that can be used to access and manipulate the data of a LetSeeMock object. These include functions to convert the data of a LetSeeMock object to and from different formats (e.g., Data, JSON, and String), and properties to access the name, data, and response code of a LetSeeMock object.
public enum LetSeeMock: Hashable, Comparable {
    /// This function is an implementation of the Comparable protocol for the LetSeeMock enumeration. It defines a comparison operator that allows LetSeeMock objects to be compared to each other using the < operator.
    ///
    /// The function defines a specific ordering for the different cases of the LetSeeMock enumeration:
    /// .live is greater than all other cases.
    /// .cancel is greater than .failure, .error, and .success.
    /// .success is greater than .failure and .error.
    /// .error is greater than .failure.
    ///
    /// This ordering is used to determine the relative position of two LetSeeMock objects in a list or other ordered collection. For example, if a list of LetSeeMock objects is sorted in ascending order, the .live cases will appear at the end of the list, the .cancel cases will appear before the .live cases, and so on.
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
    
    /// **failure**: represents a mock response that represents a failed network request. It includes the name of the mock response, the response code for the request, and the data for the response.
    case failure(name: String, response: URLError.Code, data: JSON)

    /// **success**: represents a mock response that represents a successful network request. It includes the name of the mock response, the response code for the request, and the data for the response.
    case success(name: String, response: LetSeeMockResponse? , data: JSON)

    /// **error**: represents a mock response that represents a network request that resulted in an error. It includes the name of the mock response and the error that occurred.
    case error(name: String, URLError)

    /// **live**: represents a mock response that indicates that network requests should be sent live (i.e., not mocked).
    case live

    /// **cancel**: represents a mock response that indicates that network requests should be cancelled.
    case cancel
    var data: Data? {
        self.string?.data(using: .utf8)
    }
    /**
     Returns the name of the LetSeeMock object.

     The name is a unique string value that identifies the object within the context of the app. The name is determined based on the case of the LetSeeMock object.

     For .failure and .success cases, the name is the string value passed in as an argument when the object was created. For the .error case, the name is the string value passed in as an argument when the object was created. For the .live and .cancel cases, the name is a fixed string value of "Live" and "Cancel", respectively.

     - Returns: The name of the LetSeeMock object.
     */
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

    public var type: String {
        switch self {
        case .failure: return "failure"
        case .success: return "success"
        case .error: return "error"
        case .live: return "live"
        case .cancel: return "cancel"
        }
    }
    /**
     Returns the raw data of the LetSeeMock object as a string, if possible.

     The raw data of the LetSeeMock object represents the response data that the object represents. It is expressed as a JSON object and can be modified using the `mapJson(_:)` function.

     For .failure and .success cases, the raw data is the JSON object passed in as an argument when the object was created. For the .error case, the raw data is the localized description of the error object passed in as an argument when the object was created. For the .live and .cancel cases, the raw data is `nil`.

     - Returns: The raw data of the LetSeeMock object as a string, if possible.
     */
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
