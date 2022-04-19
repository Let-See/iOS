//
//  File.swift
//  
//
//  Created by Farshad Macbook M1 Pro on 4/18/22.
//

import Foundation
struct SocketEmitableContent: Encodable {
    let type: String
    struct Data: Encodable {
        struct RequestedData: Encodable {
            let url: String
            let responseCode: String
            let method: String
            let contentLength: Int
            let headers: String
            let body: String
            init(from request: URLRequest) {
                let requestHeaders = request.allHTTPHeaderFields?.toJSON() ?? ""
                
                self.url = "\(request.url!)"
                self.responseCode = "\(request.httpMethod ?? "")"
                self.method = "\(request.httpMethod ?? "")"
                
                self.headers = "[\(requestHeaders)]"

                if let body = request.httpBody, let requestData = String(data: body, encoding: .utf8){
                    self.body = requestData
                    self.contentLength = requestData.lengthOfBytes(using: .utf8)
                    
                } else {
                    self.body = "{}"
                    self.contentLength = 0
                }
            }
        }
        let callId: Int
        let requestId: Int
        let requestData: RequestedData
        let headers: String
        let body: String
        let tookTime: String
        let contentLength: Int
        let responseCode: Int
        var waitForResponse: Bool
        init(from response: URLResponse?, responseData: Foundation.Data? , request: URLRequest) {
            self.tookTime = "-"
            self.callId = request.id
            self.requestId = request.id
            self.requestData = .init(from: request)
            self.waitForResponse = true
            if let data = responseData, let stringified = String(data: data, encoding: .utf8) {
                self.contentLength = data.count
                self.body = stringified
            } else {
                self.contentLength =  0
                self.body = "{}"
            }
            
            guard let response = response, let httpStatuse =  response as? HTTPURLResponse else {
                self.responseCode = 0
                self.headers = "[]"
                return
            }
            
            let responseHeaders = httpStatuse.allHeaderFields.toJSON()
            
            self.headers = "[\(responseHeaders)]"
            self.responseCode = httpStatuse.statusCode
            self.waitForResponse = false
        }
    }
    let data: SocketEmitableContent.Data
}

extension URLRequest {
    var id: Int {
        var hasher = Hasher()
        self.hash(into: &hasher)
        return hasher.finalize()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.httpBody)
        hasher.combine(self.url)
        hasher.combine(self.allHTTPHeaderFields)
        hasher.combine(self.httpMethod)
//        hasher.combine(Date().timeIntervalSince1970)
    }
}
