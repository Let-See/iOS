//
//  FileDirectoryProcessorTests.swift
//  
//
//  Created by Farshad Jahanmanesh on 13/01/2023.
//

import Foundation
import XCTest
@testable import LetSee

final class FileDirectoryProcessorTests: XCTestCase {
    private var sut: FileDirectoryProcessor!
    override func setUp() {
        sut = FileDirectoryProcessor(rawFileProcessor: RawDirectoryProcessor(fileManager: MockFileManager()))
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

    func testWhenToFolderAreRelativeToEachOther_makeRelativePath_shouldReturnTheDifferenceBetweenThem() {
        let mockDirectory = MockFileManager.defaultMocksDirectoryPath
        let subPath = URL(string: MockFileManager.defaultMocksDirectoryPath + "/Arrangements/innerpath")!

        let expected = "/arrangements/innerpath"
        let result = sut.makeRelativePath(for: subPath, relativeTo: mockDirectory)
        XCTAssertEqual(expected, result)
    }

    func testWhenCofnigsAvailable_shouldOverridetheRelativePath() {
        let expectedDirectoryNames = ["/innerpath/success_arrangementitemslist.json",
                                      "/innerpath/thelowestpath/success_arrangementitemslist.json",
                                      "/success_arrangementitemslist.json",
                                      "/success_arrangementsingleitem.json"].sorted()
        var mocks = try! sut.process(MockFileManager.defaultMocksDirectoryPath + "/Arrangements")
        let fileInformations = mocks.flatMap({$0.value})
        XCTAssertEqual(expectedDirectoryNames, fileInformations.map({$0.relativePath}).sorted())

        let expectedFileNames = ["success_arrangementItemsList.json",
                                 "success_arrangementItemsList.json",
                                 "success_arrangementItemsList.json",
                                 "success_arrangementSingleItem.json"].sorted()
        XCTAssertEqual(expectedFileNames, fileInformations.map({$0.name}).sorted())

        let expectedOverriddenPaths = ["/api/arrangement-manager/client-api/v2/productsummary/context/", "/api/arrangement-manager/client-api/v2/productsummary/context/orders/"]
        mocks = try! sut.process(MockFileManager.defaultMocksDirectoryPath + "/FolderWithConfig")
        let directories = mocks.map({$0.key})
        XCTAssertEqual(expectedOverriddenPaths, directories.map({$0.relativePath}).sorted())
    }

    func testWhenCofnigsAvailable_shouldOverridetheRelativePath_InnerFolderShouldRespectsTheirOwnCondigFile() {
        let expectedOverriddenPaths = ["/api/arrangement-manager/client-api/v2/productsummary/context/" , "/api/arrangement-manager/client-api/v3/orders/",
                                       "/api/arrangement-manager/v4/details/"]
            .sorted()
        let mocks = try! sut.process(MockFileManager.defaultMocksDirectoryPath + "/FolderWith2Configs")
        let directories = mocks.map({$0.key})
        XCTAssertEqual(expectedOverriddenPaths, directories.compactMap({$0.relativePath}).sorted())
    }

    func testShouldCollectScenariosCorrectly() {
        let expectedOverriddenPaths = ["HappyFlowFirstSuccessThenReject.plist" , "SuccessfulSinglePayment.plist"]
        let mocks = try! sut.process(MockFileManager.defaultMockScenariosDirectoryPath)
        let directories = mocks.flatMap({$0.value})
        XCTAssertEqual(expectedOverriddenPaths, directories.compactMap({$0.name}).sorted())
    }
}
