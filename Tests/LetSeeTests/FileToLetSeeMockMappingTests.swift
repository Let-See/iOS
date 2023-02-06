//
//  FileToLetSeeMockMappingTests.swift
//  
//
//  Created by Farshad Jahanmanesh on 30/01/2023.
//

import Foundation
import XCTest
@testable import LetSee
final class FileToLetSeeMockMappingTests: XCTestCase {
    var fileToLetSeeMockMapping: LetSee.DefaultFileToLetSeeMockMapping!
    let fileName = "fileName"
    let jsonData = Data()

    override func setUp() {
        fileToLetSeeMockMapping = LetSee.DefaultFileToLetSeeMockMapping()
    }

    func testMapSuccess() {
        let fileName = "success_fileName"
        let result = fileToLetSeeMockMapping.map(fileName: fileName, jsonData: jsonData)
        switch result {
        case .success(let name, let response, let data):
            XCTAssertEqual(name, "fileName")
            XCTAssertEqual(response?.stateCode, 200)
            XCTAssertEqual(response?.header, [:])
            XCTAssertEqual(data, jsonData)
        default:
            XCTFail("Unexpected result")
        }
    }

    func testMapFailure() {
        let fileName = "error_fileName"
        let result = fileToLetSeeMockMapping.map(fileName: fileName, jsonData: jsonData)
        switch result {
        case .failure(let name, let response, let data):
            XCTAssertEqual(name, "fileName")
            XCTAssertEqual(response, .badServerResponse)
            XCTAssertEqual(data, jsonData)
        default:
            XCTFail("Unexpected result")
        }
    }

    func testSanitize() {
        let fileName = "error_fileName"
        let result = fileToLetSeeMockMapping.sanitize(fileName)
        XCTAssertEqual(result, "fileName")
    }
}
