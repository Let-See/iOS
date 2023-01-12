//
//  DirectoryProcessorTests.swift
//  
//
//  Created by Farshad Jahanmanesh on 12/01/2023.
//

import Foundation
import XCTest
@testable import LetSee

final class DirectoryProcessorTests: XCTestCase {
    private var sut: MockDirectoryProcessor!
    override func setUp() {
        sut = MockDirectoryProcessor(fileManager: MockFileManager(), directoryToProcess: MockFileManager.defaultMocksDirectoryPath)
    }

    override func tearDown() {
        sut = nil
    }

    func testWhenDirectoryIsValid_ShowAllInformationAboutMockFiles() {
        try! sut.process()
    }

    func testWhenDirectoryIsValid_getAllFilesFromDirectoryAndSubdirectories() {
        var expectedDirectoryNames = ["InnerPath", "Arrangements", "TheLowestPath"].sorted()
        let mocks = sut.getAllChild(in: MockFileManager.defaultMocksDirectoryPath + "/Arrangements")
        XCTAssertEqual(expectedDirectoryNames, mocks.map({$0.key.lastPathComponent}).sorted())

        var expectedFileNames = ["success_arrangementItemsList.json", "success_arrangementItemsList.json", "success_arrangementItemsList.json", "success_arrangementSingleItem.json"].sorted()
        XCTAssertEqual(expectedFileNames, mocks.map({$0.value}).flatMap({$0}).map({$0.lastPathComponent}).sorted())

        expectedDirectoryNames = ["FolderWithConfig", "orders"].sorted()
        let mockFolderWithConfigs = sut.getAllChild(in: MockFileManager.defaultMocksDirectoryPath + "/FolderWithConfig")
        XCTAssertEqual(expectedDirectoryNames, mockFolderWithConfigs.map({$0.key.lastPathComponent}).sorted())

        expectedFileNames = [".pathconfigs.json", "error_rejectedPayment.json", "success_arrangementSingleItem.json", "success_validatedPayment.json"].sorted()
        XCTAssertEqual(expectedFileNames, mockFolderWithConfigs.flatMap({$0.value}).map({$0.lastPathComponent}).sorted())
    }

    func testWhenDirectoryIsValid_getAllFilesFromDirectoryAndSubdirectoriesInRootFolder() {
        let expectedDirectoryNames = ["Arrangements", "FolderWith2Configs", "FolderWithConfig", "General", "InnerPath", "Payment-orders", "TheLowestPath", "details", "orders", "orders"].sorted()
        let mocks = sut.getAllChild(in: MockFileManager.defaultMocksDirectoryPath)
        XCTAssertEqual(expectedDirectoryNames, mocks.map({$0.key.lastPathComponent}).sorted())
    }

    func testWhenToFolderAreRelativeToEachOther_makeRelativePath_shouldReturnTheDifferenceBetweenThem() {
        let mockDirectory = MockFileManager.defaultMocksDirectoryPath
        let subPath = URL(string: MockFileManager.defaultMocksDirectoryPath + "/Arrangements/innerpath")!

        let expected = "/arrangements/innerpath"
        let result = sut.makeRelativePath(for: subPath, relativeTo: mockDirectory)
        XCTAssertEqual(expected, result)
    }

    func testWhenCofnigsAvailable_shouldOverridetheRelativePath() {
        let expectedDirectoryNames = ["/arrangements/innerpath/success_arrangementitemslist.json",
                                      "/arrangements/innerpath/thelowestpath/success_arrangementitemslist.json",
                                      "/arrangements/success_arrangementitemslist.json",
                                      "/arrangements/success_arrangementsingleitem.json"].sorted()
        var mocks = sut.getAllChild(in: MockFileManager.defaultMocksDirectoryPath + "/Arrangements")
        var fileInformations = sut.map(files: mocks)
        XCTAssertEqual(expectedDirectoryNames, fileInformations.flatMap({$0.value}).map({$0.relativePath}).sorted())

        let expectedFileNames = ["success_arrangementItemsList.json",
                                 "success_arrangementItemsList.json",
                                 "success_arrangementItemsList.json",
                                 "success_arrangementSingleItem.json"].sorted()
        XCTAssertEqual(expectedFileNames, fileInformations.flatMap({$0.value}).map({$0.name}).sorted())

        let expecteOverriddenPaths = ["/api/arrangement-manager/client-api/v2/productsummary/context/folderwithconfig/", "/api/arrangement-manager/client-api/v2/productsummary/context/folderwithconfig/orders/"]
        mocks = sut.getAllChild(in: MockFileManager.defaultMocksDirectoryPath + "/FolderWithConfig")
        fileInformations = sut.map(files: mocks)
        XCTAssertEqual(expecteOverriddenPaths, fileInformations.compactMap({$0.key.relativePath}).sorted())
    }

    func testWhenCofnigsAvailable_shouldOverridetheRelativePath_InnerFolderShouldRespectsTheirOwnCondigFile() {
        let expectedOverriddenPaths = ["/api/arrangement-manager/client-api/v2/productsummary/context/folderwith2configs/" , "/api/arrangement-manager/client-api/v3/folderwith2configs/orders/",
                                       "/api/arrangement-manager/v4/folderwith2configs/details/"]
            .sorted()
        let mocks = sut.getAllChild(in: MockFileManager.defaultMocksDirectoryPath + "/FolderWith2Configs")
        let fileInformations = sut.map(files: mocks)
        XCTAssertEqual(expectedOverriddenPaths, fileInformations.compactMap({$0.key.relativePath}).sorted())
    }

    func testMockingDataParsedCorrectly() {
        let expectedOverriddenPaths = ["/api/arrangement-manager/client-api/v2/productsummary/context/folderwith2configs/" , "/api/arrangement-manager/client-api/v3/folderwith2configs/orders/",
                                       "/api/arrangement-manager/v4/folderwith2configs/details/"]
            .sorted()
        let mocks =  try? sut.process()
        XCTAssertNotNil(mocks)
    }
}
