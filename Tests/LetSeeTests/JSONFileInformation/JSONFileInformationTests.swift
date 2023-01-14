//
//  JSONFileInformationTests.swift
//  
//
//  Created by Farshad Jahanmanesh on 11/01/2023.
//

import XCTest
@testable import LetSee
extension FileInformation {
    static let successWithDelay: Self = FileInformation(name: "success_200_50ms_fileName.json", filePath: URL(string: "https://google.com")!, relativePath: "")
}
final class JSONFileInformationTests: XCTestCase {
    var sut: JSONFileNameParser!
    override func setUp() {
        sut = JSONFileNameParser()
    }
    override func tearDown() {
        sut = nil
    }

    func testsParseFunction_whenCorrectName_shouldBeAbleToParseTheFileName() {
        let fileInformation = FileInformation.successWithDelay
        let expected = MockFileInformation(fileInformation: fileInformation, statusCode: 200, delay: 50, status: .success, displayName: "FileName")
        let result = try? sut.parse(fileInformation)
        XCTAssertNotNil(result)
        XCTAssertEqual(result, expected)
    }

    func testsParseFunction_whenCorrectName_shouldBeAbleToParseTheFileNameNoStatusCodeWithDelay() {
        let fileInformation = FileInformation(name: "success_50ms_fileName.json", filePath: URL(string: "https://google.com")!, relativePath: "")
        let expected = MockFileInformation(fileInformation: fileInformation, statusCode: nil, delay: 50, status: .success, displayName: "FileName")
        let result = try? sut.parse(fileInformation)
        XCTAssertNotNil(result)
        XCTAssertEqual(result, expected)
    }

//    func testsParseFunction_whenCorrectName_shouldCorrectlyParseFileName() {
//        let allJsonFilesInGivenMockDirectory = MockFileManager().recursivelyFindAllFiles(for: MockFileManager.defaultMocksDirectoryPath, ofType: "json")
//        let path = allJsonFilesInGivenMockDirectory.first!
//        let fileInformation = try! sut.parse(path)
//        XCTAssertTrue("\(fileInformation.type)_\(fileInformation.name).\(fileInformation.fileType)".caseInsensitiveCompare(path.lastPathComponent) == .orderedSame)
//        XCTAssertEqual(fileInformation.filePath, path)
//        XCTAssertEqual(fileInformation.filePath, path)
//    }
//
//    func testsParseFunction_whenCorrectName_shouldCorrectlyParseDetailsFileName() {
//        let allJsonFilesInGivenMockDirectory = MockFileManager().recursivelyFindAllFiles(for: MockFileManager.defaultMocksDirectoryPath, ofType: "json")
//        var path = allJsonFilesInGivenMockDirectory.first!
//        var lastComponent = "success_200_50ms_fileName.json"
//        var updatedPath = path.absoluteString.replacingOccurrences(of: path.lastPathComponent, with: lastComponent)
//        let expectedDetails = FileInformation.Details(statusCode: 200, delay: 50, baseURL: nil)
//        let expectedResult = FileInformation(name: "FileName", type: "success", filePath: URL(fileURLWithPath: updatedPath), fileType: "json", details: expectedDetails)
//        let fileInformation = try! sut.parse(URL(fileURLWithPath: updatedPath))
//
//        XCTAssertEqual(fileInformation, expectedResult)
//    }
//
//    func testsParseFunction_whenCorrectName_shouldReturnErrorIfFileNameIsNotParsable() {
//        let allJsonFilesInGivenMockDirectory = MockFileManager().recursivelyFindAllFiles(for: MockFileManager.defaultMocksDirectoryPath, ofType: "json")
//        var path = allJsonFilesInGivenMockDirectory.first!
//        var lastComponent = "fileName.json"
//        var updatedPath = path.absoluteString.replacingOccurrences(of: path.lastPathComponent, with: lastComponent)
//        XCTAssertThrowsError(try sut.parse(URL(fileURLWithPath: updatedPath)))
//    }

}
