//
//  ScenarioFileInformationTests.swift
//  
//
//  Created by Farshad Jahanmanesh on 14/01/2023.
//

import XCTest
@testable import LetSee
final class ScenarioFileInformationTests: XCTestCase {
    func test_whenInitFromDecoder_WrapFolderNameBetweenTwoForwardSlash() {
        let folder = "Arrangements"
        let responseFileName = "success_fullName"
        let result = ScenarioFileInformation.Step(folder: folder, responseFileName: responseFileName)
        XCTAssertEqual("/\(folder.lowercased())/", result.folder)
        XCTAssertEqual(responseFileName.lowercased(), result.responseFileName)
    }

    func test_whenInitFromDecoder_WrapFolderNameByFixEndSlash() {
        let folder = "/Arrangements"
        let responseFileName = "success_fullName"
        let result = ScenarioFileInformation.Step(folder: folder, responseFileName: responseFileName)
        XCTAssertEqual("\(folder.lowercased())/", result.folder)
        XCTAssertEqual(responseFileName.lowercased(), result.responseFileName)
    }

    func test_whenInitFromDecoder_WrapFolderNameByFixFirstSlash() {
        let folder = "Arrangements/"
        let responseFileName = "success_fullName"
        let result = ScenarioFileInformation.Step(folder: folder, responseFileName: responseFileName)
        XCTAssertEqual("/\(folder.lowercased())", result.folder)
        XCTAssertEqual(responseFileName.lowercased(), result.responseFileName)
    }
}
