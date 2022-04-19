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
            
            server["/ws"] = websocket( text: {[weak self] (session, text) in
                self?.socket = session
                self?.reduceQueue()
            },binary: { (session, binary) in
                session.writeBinary(binary)
            })
            
            try server.start()
            
            print("Server has started (\(ipAddress):\(port)/). Try to connect now...")
        } catch {
            print("Server start error: \(error)")
            // Handle error here
        }
    }
    
    
    private func print(_ message: String) {
        Swift.print("@LETSEE> ", message)
    }
    
    private func reduceQueue() {
        while !queue.isEmpty {
            guard let socket = socket, let item = queue.popLast() else {return}
            socket.writeText(item)
        }
    }
    
    //    private var calls: [URLRequest: URLResponse] = []
    
    private var queue: [String] = []
    
    @discardableResult
    public func log(_ log: Log) -> JSON? {
        switch log {
        case .request(let request):
            return self.emit(event: .init(type: "REQUEST", data: .init(from: nil, responseData: nil, request: request)))
        case .response(let request, let response, let body):
            return self.emit(event: .init(type: "REQUEST", data: .init(from: response, responseData: body, request: request)))
        }
    }
    
    @discardableResult
    private func emit(event: SocketEmitableContent) -> JSON? {
        guard let jsonEncoder = try? JSONEncoder().encode(event), let json = String(data:jsonEncoder, encoding: .utf8) else {
            return nil
        }
        
        if let socket = self.socket {
            socket.writeText(json)
        } else {
            queue.append(json)
        }
        return json
    }
    
    public enum Log {
        case request(request: URLRequest)
        case response(request: URLRequest, response: URLResponse, body: Data?)
    }
}
