//
//  File.swift
//  
//
//  Created by Farshad Macbook M1 Pro on 4/18/22.
//

import Foundation
@testable import LetSee
import XCTest

final class WebServerTests: XCTestCase {
    var sut: WebServer!
    
    override func setUpWithError() throws {
        sut = WebServer(apiBaseUrl: "www.apple.com")
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
    
#if os(macOS)
    func testPort() {
        XCTAssertEqual(sut.port, 9080)
    }
    
    func testIpAddress() {
        XCTAssertEqual(sut.ipAddress, "127.0.0.1")
    }
    
    func testUrl() {
        XCTAssertEqual(sut.url, URL(string: "http://127.0.0.1:9080")!)
    }
#endif
    
#if os(iOS)
    func testPort() {
        XCTAssertEqual(sut.port, 8080)
    }
    
    func testIpAddress() {
        XCTAssertEqual(sut.ipAddress, UIDevice.current.ipAddress)
    }
    
    func testUrl() {
        XCTAssertEqual(sut.url, URL(string: "http://\(UIDevice.current.ipAddress):8080")!)
    }
    
    func testMessage() {
        let data = """
{
    "userId": 1,
    "id": 1,
    "title": "delectus aut autem",
    "completed": false
}
"""
        let emit = sut.log(request: .init(url: URL(string: "https://google.com")!), data: data.data(using: .utf8), response: .init(url: URL(string: "https://google.com")!, statusCode: 200, httpVersion: nil, headerFields: ["response": "google"]), error: nil)
        XCTAssertNotNil(emit)
    }
#endif
}
