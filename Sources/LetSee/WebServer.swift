//
//  WebServer.swift
//  
//
//  Created by Farshad Macbook M1 Pro on 4/18/22.
//

import Foundation
import Swifter
import SafariServices

/// Our `WebServer`is the place that we prepare and provide event data for our HTML page. Its responsibility is queuing and sending new logs to HTML via a Socket Connection.
/// At the beginning of the application, it is probable that our socket connection isn't connected yet, in this case, the WebServer,
/// caches and queues the logs then immediately after a successful connection of our web application socket with our server socket, it emits all the queued logs to the Web application.
///
public final class WebServer: NSObject {
    public typealias JSON = String

    private var socket: WebSocketSession!
    private let server = HttpServer()
    private var queue: [String] = []
    public var url: URL {
        return URL(string: "http://" + ipAddress + ":" + String(port))!
    }
#if SWIFT_PACKAGE
    private var bundle: Bundle {
        return .module
    }
#else
    private var bundle: Bundle {
        // Get the bundle containing the binary with the current class.
        // If frameworks are used, this is the frameworks bundle (.framework),
        // if static libraries are used, this is the main app bundle (.app).
        let myBundle = Bundle(for: Self.self)

        // Get the URL to the resource bundle within the bundle
        // of the current class.
        guard let resourceBundleURL = myBundle.url(
            forResource: "LetSee", withExtension: "bundle")
            else { fatalError("LetSee.bundle not found!") }

        // Create a bundle object for the bundle found at that URL.
        guard let resourceBundle = Bundle(url: resourceBundleURL)
            else { fatalError("Cannot access LetSee.bundle!") }
        
        return resourceBundle
    }
#endif
    
    private var apiBaseUrl: String = "BASE_URL"
    
#if os(macOS)
    public var port: Int {
        return 9080
    }
#else
    public var port: Int {
        return 8080
    }
#endif
    
#if os(iOS)
    public let ipAddress: String = {
        return UIDevice.current.ipAddress
    }()
#else
    public let ipAddress: String = {
        return "127.0.0.1"
    }()
#endif

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
            
            print("Server has started (\(ipAddress):\(port)/). \n you can open the logger application by copyign this address in your browser.")
        } catch {
            print("Server start error: \(error)")
        }
    }
    
    /// Adds @LETSEE>  at the beging of the print statement
    ///
    /// - Parameters:
    ///    - message: the print string
    private func print(_ message: String) {
        Swift.print("@LETSEE> ", message)
    }
    
    /// Reducs the queued item while the socket is connected and there is item in queue, every time the socket disconnects, we need to catch the requests and emit them after the socket reconnected.
    private func reduceQueue() {
        while !queue.isEmpty {
            guard let socket = socket, let item = queue.popLast() else {return}
            socket.writeText(item)
        }
    }
    
    @discardableResult
    public func log(_ log: Log) -> JSON? {
        switch log {
        case .request(let request):
            return self.emit(event: .init(with: request))
        case .response(let request, let response, let body):
            return self.emit(event: .init(kind: .response, request: request, response: response, body: body))
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
