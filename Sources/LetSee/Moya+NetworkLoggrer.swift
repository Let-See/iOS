//
//  File.swift
//  
//
//  Created by Farshad Macbook M1 Pro on 4/19/22.
//

#if canImport(Moya)
import Foundation
import Moya

/// a plug to automate whole usage of LetSee library
///
/// - How to use?
///     - ......
///     - `provider = MoyaProvider<Apis>(plugins:[LetSeeLogs()])`
///     - ......
///
/// and now just look at your console for the server ip address. you can filter the console by '@LETSEE>' if there are alot of lines in your console.
public final class LetSeeLogs: PluginType {
    let webServer: WebServer
    
    /// - Paramters:
    ///     - baseUrl: an optional text. this is just a text which `LetSee` uses it in the HTML page.
    public init(baseUrl: String = "") {
        webServer = .init(apiBaseUrl: baseUrl)
    }
    
    /// we add an id to headers of the request. this id helps us to find the pending request (this request) easly
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        request.headers.update(name: "LETSEE-LOGGER-ID", value: UUID().uuidString)
        webServer.log(.request(request: request))
        return request
    }
    
    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case.success(let response):
            guard let request = response.request, let urlResponse = response.response else {return}
            webServer.log(.response(request: request, response: urlResponse, body: response.data))
        case .failure(let error):
            guard let request = error.response?.request, let urlResponse = error.response?.response else {return}
            webServer.log(.response(request: request, response: urlResponse, body: error.errorDescription?.data(using: .utf8) ?? Data()))
        }
        
    }
}
#endif
