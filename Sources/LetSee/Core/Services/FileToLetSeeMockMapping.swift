//
//  FileToLetSeeMockMapping.swift
//  
//
//  Created by Farshad Jahanmanesh on 08/01/2023.
//

import Foundation
public protocol FileToLetSeeMockMapping {
    func map(fileName: String, jsonData: Data) -> LetSeeMock
    func sanitize(_ fileName: String) -> String
}

extension LetSee {
    struct DefaultFileToLetSeeMockMapping: FileToLetSeeMockMapping {
        func map(fileName: String, jsonData: Data) -> LetSeeMock {
            let sanitizedFileName = self.sanitize(fileName)

            if fileName.components(separatedBy: "/").last!.starts(with: "success_") {
                return LetSeeMock.success(name: sanitizedFileName, response: .init(stateCode: 200, header: [:]), data: jsonData)
            } else {
                return LetSeeMock.failure(name: sanitizedFileName, response: .badServerResponse, data: jsonData)
            }
        }

        func sanitize(_ fileName: String) -> String {
            fileName
            .replacingOccurrences(of: "error_", with: "")
            .replacingOccurrences(of: "success_", with: "")
        }
    }
}
