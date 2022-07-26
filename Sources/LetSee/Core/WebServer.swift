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
/// Our `WebServer`is the place that we prepare and provide event data for our HTML page. Its responsibility is queuing and sending new logs to HTML via a Socket Connection.
/// At the beginning of the application, it is probable that our socket connection isn't connected yet, in this case, the WebServer,
/// caches and queues the logs then immediately after a successful connection of our web application socket with our server socket, it emits all the queued logs to the Web application.
///
public final class WebServer: NSObject {

	private var sockets: [WebSocketSession?] = []
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
		return Bundle(for: Self.self)
	}
#endif

	private var apiBaseUrl: String = "BASE_URL"

#if os(macOS)
	public var port: Int {
		return 9080
	}
#else
	public var port: Int {
		return 3000
	}
#endif

#if targetEnvironment(simulator)
	public let ipAddress: String = {
		return "127.0.0.1"
	}()
#elseif os(iOS)
	public let ipAddress: String = {
		return UIDevice.current.ipAddress
	}()
#else
	public let ipAddress: String = {
		return "127.0.0.1"
	}()
#endif

	public var loggerAddress: String {
		"\(ipAddress):\(port)"
	}

	public init(apiBaseUrl: String) {
		super.init()
		self.apiBaseUrl = apiBaseUrl
		do {

			let website = bundle.path(forResource: "build", ofType: nil, inDirectory: "Website")!
			let indexHTML = bundle.path(forResource: "index", ofType: "html", inDirectory: "Website/build")!
			let indexData = try String(contentsOfFile: indexHTML).data(using: .utf8)!

			server["/"] = { _ in
					.ok(.data(indexData, contentType: "html"))
			}

			server["/api/config"] = { _ in
					.raw(200, "", ["Access-Control-Allow-Origin":"*"]) { body in
					try! body.write("{\"webSocketPort\": \(self.port), \"baseURL\": \"\(self.apiBaseUrl)\"}".data(using: .utf8)!)
				}
			}

			server["/:path"] = directoryBrowser(website + "/")
			server["/resources/:path"] = directoryBrowser(website)
			server["/static/css/:path"] = directoryBrowser(website + "/static/css")
			server["/static/js/:path"] = directoryBrowser(website + "/static/js")

			server["/api/ws"] = websocket( text: {[weak self] (session, text) in
				self?.sockets.append(session)
				
				self?.reduceQueue()
			},binary: { (session, binary) in
				session.writeBinary(binary)
			}, disconnected: {[weak self]  session in
				self?.sockets.removeAll(where: {session == $0})
			})
			server.listenAddressIPv6 = ipAddress
			server.listenAddressIPv4 = ipAddress
			try server.start(in_port_t(port))

			print("Server has started (\(ipAddress):\(port)/). \n you can open the logger application by coping this address in your browser.")
		} catch {
			print("Server start error: \(error)")
		}
	}

	/// Reducs the queued item while the socket is connected and there is item in queue, every time the socket disconnects, we need to catch the requests and emit them after the socket reconnected.
	private func reduceQueue() {
		while !queue.isEmpty {
			guard let item = queue.popLast() else {return}
			sockets.forEach({ socket in
				socket?.writeText(item)
			})
		}
	}

	@discardableResult
	public func log(_ log: Log) -> JSON? {
		switch log {
		case .request(let request):
			return self.emit(event: .init(with: request))
		case .response(let response, let request, let body):
			return self.emit(event: .init(kind: .response, request: request, response: response, body: body))
		}
	}

	@discardableResult
	private func emit(event: SocketEmitableContent) -> JSON? {
		guard let jsonEncoder = try? JSONEncoder().encode(event), let json = String(data:jsonEncoder, encoding: .utf8) else {
			return nil
		}

		queue.append(json)
		reduceQueue()
		return json
	}

	public enum Log {
		case request(_ request: URLRequest)
		case response(_ response: URLResponse, forRequest: URLRequest, withBody: Data?)
	}
}
