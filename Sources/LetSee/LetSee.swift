import Foundation
final public class LetSee {
    public private(set) var webServer: WebServer
    /// logger address, you can open this address in your device browser to see the LetSee web application
    public var address: String {
        "http://\(webServer.loggerAddress)"
    }
    public init(_ baseUrl: String = "") {
        self.webServer = .init(apiBaseUrl: baseUrl)
    }
    
    /// we add an id to headers of the request. this id helps LetSee to find the pending request easly
    public func addID(to request: URLRequest) -> URLRequest {
        return request.addID()
    }
    
    @discardableResult
    public func log(_ log: WebServer.Log) -> JSON? {
        return self.webServer.log(log)
    }
}

extension LetSee {
    static let headerKey: String = "LETSEE-LOGGER-ID"
}
