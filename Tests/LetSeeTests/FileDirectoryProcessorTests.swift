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
        let expectedOverriddenPaths = ["/api/arrangement-manager/client-api/v2/productsummary/context/arrangements/", "/api/arrangement-manager/client-api/v2/productsummary/context/arrangements/innerpath/", "/api/arrangement-manager/client-api/v2/productsummary/context/arrangements/innerpath/thelowestpath/"]
        let expectedOverriddenFiles = ["/arrangements/innerpath/success_arrangementitemslist.json",
                                       "/arrangements/innerpath/thelowestpath/success_arrangementitemslist.json",
                                       "/arrangements/success_arrangementitemslist.json",
                                       "/arrangements/success_arrangementsingleitem.json"].sorted()
        let mocks = try! sut.process(MockFileManager.defaultMocksDirectoryPath)
        let directories = mocks.map({$0.key}).filter({$0.path.absoluteString.contains("/Mocks/Arrangements/")})
        let files = mocks.flatMap({$0.value}).filter({$0.relativePath.hasPrefix("/arrangements/")})
        XCTAssertEqual(expectedOverriddenPaths, directories.compactMap({$0.relativePath}).sorted())
        XCTAssertEqual(expectedOverriddenFiles, files.map({$0.relativePath}).sorted())

        let expectedFileNames = ["success_arrangementItemsList.json",
                                 "success_arrangementItemsList.json",
                                 "success_arrangementItemsList.json",
                                 "success_arrangementSingleItem.json"].sorted()
        XCTAssertEqual(expectedFileNames, files.map(\.name).sorted())
    }

    func testWhenCofnigsAvailable_shouldOverridetheRelativePath_InnerFolderShouldRespectsTheirOwnCondigFile() {
        let expectedOverriddenPaths = ["/api/arrangement-manager/v4/details/folderwith2configs/" , "/api/arrangement-manager/v3/orders/folderwith2configs/orders/",
                                       "/api/arrangement-manager/v4/details/folderwith2configs/details/"]
            .sorted()
        let mocks = try! sut.process(MockFileManager.defaultMocksDirectoryPath)
        let directories = mocks.map({$0.key}).filter({$0.path.absoluteString.contains("/Mocks/FolderWith2Configs/")})
        XCTAssertEqual(expectedOverriddenPaths, directories.compactMap({$0.relativePath}).sorted())
    }

    func testShouldCollectScenariosCorrectly() {
        let expectedOverriddenPaths = ["HappyFlowFirstSuccessThenReject.plist" , "SuccessfulSinglePayment.plist"]
        let mocks = try! sut.process(MockFileManager.defaultMockScenariosDirectoryPath)
        let directories = mocks.flatMap({$0.value})
        XCTAssertEqual(expectedOverriddenPaths, directories.compactMap({$0.name}).sorted())
    }

    func test_whenGlobalConfigIsAvailable_theMapsArrayShouldSortDescBasedOnFoldersName() {
        let json = GlobalMockDirectoryConfig.mockJSON
        let globalConfigs = try! JSONDecoder().decode(GlobalMockDirectoryConfig.self, from: json.data(using: .utf8)!)
        let expected = ["/folderwith2configs/orders/", "/folderwith2configs/", "/arrangements/"]
        let result = globalConfigs.maps.map({$0.folder})
        XCTAssertEqual(expected, result)
    }

    func test_whenGlobalConfigsHasMap_ItShouldReturnACorrectMapForSpecificFolderPath() {
        let json = GlobalMockDirectoryConfig.mockJSON
        let globalConfigs = try! JSONDecoder().decode(GlobalMockDirectoryConfig.self, from: json.data(using: .utf8)!)
        let expected = GlobalMockDirectoryConfig.Map(folder: "/arrangements/", to: "/api/arrangement-manager/client-api/v2/productsummary/context")
        let result = globalConfigs.hasMap(for: expected.folder)
        XCTAssertNotNil(result)
        XCTAssertEqual(expected, result)
    }

    func test_whenGlobalConfigsHasMap_shouldLowerCasedAllValues_onDecoding() {
        let json = GlobalMockDirectoryConfig.mockJSON
        let globalConfigs = try! JSONDecoder().decode(GlobalMockDirectoryConfig.self, from: json.data(using: .utf8)!)
        let expected = GlobalMockDirectoryConfig.Map(folder: "/Arrangements/", to: "/Api/Arrangement-manager/client-api/v2/Productsummary/Context")
        let result = globalConfigs.hasMap(for: expected.folder)

        XCTAssertEqual(expected.folder.lowercased(), result?.folder)
        XCTAssertEqual(expected.to.lowercased(), result?.to)
    }

    func test_whenInitAMap_shouldLowerCasedAllValues() {
        let folder = "/Arrangements/"
        let to = "/Api/Arrangement-manager/client-api/v2/Productsummary/Context"
        let result = GlobalMockDirectoryConfig.Map(folder: folder, to: to)

        XCTAssertEqual(folder.lowercased(), result.folder)
        XCTAssertEqual(to.lowercased(), result.to)
    }
}

extension GlobalMockDirectoryConfig {
    static var mockJSON: String { """
{
    "maps": [
        {
            "folder": "/arrangements/",
            "to": "/api/arrangement-manager/client-api/v2/productsummary/context"
        },
        {
            "folder": "/folderWith2Configs/",
            "to": "/api/arrangement-manager/v4/details"
        },
        {
            "folder": "/folderWith2Configs/orders/",
            "to": "/api/arrangement-manager/v3/orders"
        }
    ]
}


"""}
}
