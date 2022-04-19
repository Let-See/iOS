//
//  File.swift
//  
//
//  Created by Farshad Macbook M1 Pro on 4/18/22.
//

import Foundation

struct SocketEmitableContent: Encodable {
    /// type of emition
    let type: Kind
    let id: String
    let request: Content<URLRequest>
    let response: Content<URLResponse>?
    var waiting: Bool
    
    init(with request: URLRequest) {
        self.init(kind: .request, request: request, response: nil, body: nil)
    }
    
    init(kind: Kind, request: URLRequest, response: URLResponse?, body: Data?) {
        self.type = kind
        id = request.value(forHTTPHeaderField: "LETSEE-LOGGER-ID") ?? UUID().uuidString
        self.request = .init(activity: request)
        if let response = response{
            self.response = .init(activity: response, body: body)
            waiting = false
        } else {
            self.response = nil
            waiting = true
        }
    }
}

extension SocketEmitableContent {
    struct Content<RequestResponse>: Encodable {
        let headers: [KeyValue<String,String>] = []
        let tookTime: String = "-"
        let contentLength: Int = 0
        let statusCode: Int? = nil
        let activity: RequestResponse
        let body: Data?
        let method: String? = nil
        let url: String = ""
        enum CodingKeys: String, CodingKey {
            case headers = "headers"
            case tookTime = "took_time"
            case contentLength = "content_length"
            case statusCode = "status_code"
            case response = "response"
            case body = "body"
            case method, url
        }
        
        init(activity: RequestResponse, body: Data? = nil) {
            self.activity = activity
            self.body = body
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: Self.CodingKeys)
            
            if let httpRes = activity as? HTTPURLResponse {
                try container.encode(httpRes.allHeaderFields.asKeyValue, forKey: .headers)
                try container.encode(httpRes.statusCode, forKey: .statusCode)
            } else if let httpReq = activity as? URLRequest {
                try container.encode((httpReq.allHTTPHeaderFields?.asKeyValue ?? []), forKey: .headers)
                try container.encode(0, forKey: .statusCode)
                try container.encode(httpReq.httpMethod ?? "", forKey: .method)
                try container.encode(httpReq.url, forKey: .url)
                if let data = httpReq.httpBody, let stringified = String(data: data, encoding: .utf8) {
                    try container.encode(stringified, forKey: .body)
                }
            }
            
            if let data = body, let stringified = String(data: data, encoding: .utf8) {
                try container.encode(stringified, forKey: .body)
                try container.encode(data, forKey: .contentLength)
            } else {
                try container.encode("{}", forKey: .body)
                try container.encode(0, forKey: .contentLength)
            }
            
            try container.encode("-", forKey: .tookTime)
        }
    }
}

extension SocketEmitableContent {
    enum Kind: String, Codable {
        case request, response
    }
}
