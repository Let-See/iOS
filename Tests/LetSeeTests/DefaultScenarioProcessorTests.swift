//
//  DefaultScenarioProcessorTests.swift
//  
//
//  Created by Farshad Jahanmanesh on 14/01/2023.
//

import Foundation
import XCTest
@testable import LetSee

final class DefaultScenarioProcessorTests: XCTestCase {
    private var sut: DefaultScenarioProcessor!
    override func setUp() {
        sut = DefaultScenarioProcessor()
    }

    override func tearDown() {
        sut = nil
    }

    func testWhenDirectoryIsValid_getAllFilesFromDirectoryAndSubdirectories() {
        let configs = GlobalMockDirectoryConfig.isExists(in: URL(fileURLWithPath: MockFileManager.defaultMocksDirectoryPath))!
        let mockProcessor = DefaultMockProcessor()
        let mocks = try! mockProcessor.buildMocks(MockFileManager.defaultMocksDirectoryPath)
        var scenarios = try! sut.buildScenarios(for: MockFileManager.defaultMockScenariosDirectoryPath, requestToMockMapper: {path in
            DefaultRequestToMockMapper.transform(request: URL(string: "https://letsee.com/" + path)!, using: mocks)
        }, globalConfigs: configs)
        XCTAssertTrue(scenarios.count > 0)
        let successfulSinglePayment = scenarios.first(where: {$0.name == "SuccessfulSinglePayment"})
        XCTAssertNotNil(successfulSinglePayment)
        XCTAssertEqual(successfulSinglePayment?.mocks.count, 3)
        let expectedMocksName =  ["ArrangementSingleItem", "ArrangementItemsList", "ValidatedPayment"].sorted()
        XCTAssertEqual(successfulSinglePayment?.mocks.map(\.name).sorted(), expectedMocksName)
    }
}
