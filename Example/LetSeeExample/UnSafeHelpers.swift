//
//  UnSafeHelpers.swift
//  LetSee+CocoaPods
//
//  Created by Farshad Macbook M1 Pro on 4/24/22.
//
/// ** Caution **
/// **Content in this files are just for sample and mocking, it is not safe to use any of below codes in a real world scenario**

import Foundation
struct TestModel: Codable {
    let name: String
    let family: String
    let id: String
    
    init(name:String = "Some name", family: String = "Some Family", id: String = UUID().uuidString) {
        self.name = name
        self.family = family
        self.id = id
    }
}

/// ** Caution **
/// **Content in this files are just for sample and mocking, it is not safe to use any of below codes in a real world scenario**
class MockUrlProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        let urlresponse = HTTPURLResponse(url: request.url!, statusCode: (200..<400).randomElement()!, httpVersion: nil, headerFields: nil)

        client?.urlProtocol(self, didReceive: urlresponse!, cacheStoragePolicy: .allowed)
        let model = TestModel(name: "Response Name", family: "Response some family", id: "Response some id")
        let data = try! JSONEncoder().encode(model)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
        
    }
}

/// ** Caution **
/// **Content in this files are just for sample and mocking, it is not safe to use any of below codes in a real world scenario**
var mockSession: URLSession = {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockUrlProtocol.self]
    return URLSession(configuration: config)
}()

/// ** Caution **
/// **Content in this files are just for sample and mocking, it is not safe to use any of below codes in a real world scenario**
extension URLRequest {
    static var randomRequest: URLRequest {
        var request = URLRequest(url: URL(string: "https://api.somesite.com")!)
        request.httpMethod = ["POST", "GET", "PUT", "PATCH"].randomElement()!
        request.timeoutInterval =  Double((1..<5).randomElement()!)
        if request.httpMethod == "POST" {
            request.httpBody = try! JSONEncoder().encode(TestModel())
        }
        return request
    }
}
