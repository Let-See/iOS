//
//  WebServer.swift
//  
//
//  Created by Farshad Macbook M1 Pro on 4/18/22.
//

import Foundation
import Swifter
import SafariServices
public typealias JSON = String
public final class WebServer: NSObject {
    private var socket: WebSocketSession!
    private let server = HttpServer()
    public var port: Int {
#if os(macOS)
        return 9080
#else
        return 8080
#endif
    }
    
    public let ipAddress: String = {
#if os(iOS)
        return UIDevice.current.ipAddress
#else
        return "127.0.0.1"
#endif
    }()
    
    public var url: URL {
        return URL(string: "http://" + ipAddress + ":" + String(port))!
    }
    
    private var bundle: Bundle {
        return .module
    }
    
    private var apiBaseUrl: String = "BASE_URL"
    
    public init(apiBaseUrl: String) {
        super.init()
        self.apiBaseUrl = apiBaseUrl
        do {
            let website = bundle.path(forResource: "logger", ofType: nil, inDirectory: "Website")!
            let indexHTML = bundle.path(forResource: "index", ofType: "html", inDirectory: "Website/logger")!
            let indexData = try String(contentsOfFile: indexHTML).data(using: .utf8)!
            
            server["/"] = { _ in
                    .ok(.data(indexData, contentType: "html"))
            }
            
            server["/config"] = { _ in
                    .ok(.text("{\"webSocketPort\": \(self.port), \"baseURL\": \"\(self.apiBaseUrl)\"}"))
            }
            
            server["/resources/:path"] = directoryBrowser(website)
            
            server["/ws"] = websocket( text: { (session, text) in
                self.socket = session
            },binary: { (session, binary) in
                session.writeBinary(binary)
            })
            
            try server.start()
            
            print("@Server has started (\(ipAddress):\(port)/). Try to connect now...")
        } catch {
            print("@Server start error: \(error)")
            // Handle error here
        }
    }
    
    @discardableResult
    public func log(request: URLRequest,
                    data:Data?,
                    response: HTTPURLResponse?,
                    error: Error?) -> JSON? {
        
//        let data = data == nil ? "{}" : String(data: data!, encoding: .utf8)
//        let requestData = request.httpBody == nil ? "{}" : String(data: request.httpBody!, encoding: .utf8)
//        let httpResponse = response ?? .init()
        
        let jsonObject = SocketEmitableContent(type: "RESPONSE", data: .init(from: response, responseData: data, request: request))
//        let json = """
//        {
//            "type": "RESPONSE",
//            "data": {
//                "callId": 0,
//                "requestData": {
//                        "url": "\(request.url!)",
//                        "responseCode": "\(request.httpMethod ?? "")",
//                        "method": "\(request.httpMethod ?? "")",
//                        "contentLength":"\(response?.expectedContentLength ?? 0)",
//                        "headers": [\(requestHeaders)],
//                        "body": \(requestData ?? "{}")
//                },
//                "headers": [\(responseHeaders)],
//                "body": \(data ?? "{}"),
//                "tookTime": "-",
//                "contentLength": \(data?.count ?? 0),
//                "responseCode": "\(httpResponse.statusCode)"
//            }
//        }
//        """

        return self.emit(event: jsonObject)
    }
    
    @discardableResult
    private func emit(event: SocketEmitableContent) -> JSON? {
        guard let jsonEncoder = try? JSONEncoder().encode(event), let json = String(data:jsonEncoder, encoding: .utf8) else {
            return nil
        }
        self.socket?.writeText(json)
        return json
    }
    
}
