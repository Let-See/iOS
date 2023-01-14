//
//  RawDirectoryProcessorTests.swift
//  
//
//  Created by Farshad Jahanmanesh on 13/01/2023.
//
import Foundation
import XCTest
@testable import LetSee

final class RawDirectoryProcessorTests: XCTestCase {
    private var sut: RawDirectoryProcessor!
    override func setUp() {
        sut = RawDirectoryProcessor(fileManager: MockFileManager())
    }

    override func tearDown() {
        sut = nil
    }

    func testWhenDirectoryIsValid_getAllFilesFromDirectoryAndSubdirectories() {
        var expectedDirectoryNames = ["InnerPath", "Arrangements", "TheLowestPath"].sorted()
        let mocks = try! sut.process(MockFileManager.defaultMocksDirectoryPath + "/Arrangements")
        XCTAssertEqual(expectedDirectoryNames, mocks.map({$0.key.path.lastPathComponent}).sorted())

        var expectedFileNames = ["success_arrangementItemsList.json", "success_arrangementItemsList.json", "success_arrangementItemsList.json", "success_arrangementSingleItem.json"].sorted()
        XCTAssertEqual(expectedFileNames, mocks.map({$0.value}).flatMap({$0}).map({$0.url.lastPathComponent}).sorted())

        expectedDirectoryNames = ["FolderWithConfig", "orders"].sorted()
        let mockFolderWithConfigs = try! sut.process(MockFileManager.defaultMocksDirectoryPath + "/FolderWithConfig")
        XCTAssertEqual(expectedDirectoryNames, mockFolderWithConfigs.map({$0.key.path.lastPathComponent}).sorted())

        expectedFileNames = [".pathconfigs.json", "error_rejectedPayment.json", "success_arrangementSingleItem.json", "success_validatedPayment.json"].sorted()
        XCTAssertEqual(expectedFileNames, mockFolderWithConfigs.flatMap({$0.value}).map({$0.url.lastPathComponent}).sorted())
    }
}
