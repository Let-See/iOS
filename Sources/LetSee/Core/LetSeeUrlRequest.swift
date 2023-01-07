//
//  LetSeeUrlRequest.swift
//  
//
//  Created by Farshad Jahanmanesh on 07/01/2023.
//

import Foundation
/*
 Represents a request in the LetSee library. It has the following properties:
 `request`: The original `URLRequest` object.
 `mocks`: An array of `CategorisedMocks` objects that contain the available mocks for the request.
 `response`: A closure that is called when a response is available for the request.
 `status`: An enum that represents the status of the request. It can be one of `idle`, `sendingToServer`, or `responded`.
*/
public struct LetSeeUrlRequest {

    /// The original `URLRequest` object.
    public var request: URLRequest

    /// An array of `CategorisedMocks` objects that contain the available mocks for the request.
    public var mocks: Array<CategorisedMocks>

    /// A closure that is called when a response is available for the request.
    public var response: ((Result<LetSeeSuccessResponse, LetSeeError>)->Void)?

    /// An enum that represents the status of the request. It can be one of `idle`, `sendingToServer`, or `responded`.
    public var status: LetSeeRequestStatus

    /// This method returns the name of the request based on the given parameters. If removeString is set, it removes that string from the request name.
    /// This function is useful for the time we want to remove the baseURL from the request name
    /// - Parameters:
    ///   - removeString: If it is provided, it removes this string from the name
    /// - Returns: request name in lowercase
    public func nameBuilder(remove cutBaseURL: String? = nil) -> String {
        guard let name = request.url?.absoluteString else {return ""}
        guard let cutBaseURL else {return name}
        return name.lowercased().replacingOccurrences(of: cutBaseURL, with: "")
    }

    public init(request: URLRequest, mocks: [CategorisedMocks]? = nil, response: ((Result<LetSeeSuccessResponse, LetSeeError>) -> Void)? = nil, status: LetSeeRequestStatus) {
        self.request = request
        self.mocks = mocks ?? []
        self.response = response
        self.status = status
    }
}
