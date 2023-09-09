//
//  LetSee+URLProtocol.swift
//  
//
//  Created by Farshad Macbook M1 Pro on 5/1/22.
//

import Foundation
/**
 A custom URL protocol for intercepting network requests and responses and applying mock scenarios.
 */
public final class LetSeeURLProtocol: URLProtocol {
    
    // MARK: - Properties
    
    /// The `RequestInterceptor` object used to intercept network requests and responses.
    public static unowned var letSee: RequestInterceptor!
    
    // MARK: - URLProtocol
    
    /**
     Returns the canonical version of the specified request.
     
     - Parameters:
     - request: The request to canonicalize.
     - Returns: The canonical version of the request.
     */
    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        var _request = request
        // Set the timeout interval to a large value
        _request.timeoutInterval = 3600
        return _request
    }
    
    /**
     Determines whether the URL protocol can handle the specified request.
     
     - Parameters:
     - request: The request to handle.
     - Returns: `true` if the URL protocol can handle the request, `false` otherwise.
     */
    public override class func canInit(with request: URLRequest) -> Bool {
        // Return whether mock is enabled in the configuration
        LetSee.shared.configuration.isMockEnabled
    }
    
    /**
     Starts loading the request.
     */
    public override func startLoading() {
        let client = self.client
        // Prepare the request using the RequestInterceptor
        Self.letSee.prepare(request: self.request, resultHandler: {[weak self] result in
            guard let self = self else {return}
            
            // Handle the result of the request preparation
            switch result {
            case .success((let response, let data)):
                
                // If the request was successful, send the response and data to the client
                client?.urlProtocol(self, didReceive: response!, cacheStoragePolicy: .notAllowed)
                client?.urlProtocol(self, didLoad: data!)
            case .failure(let error):
                if let data = error.data {
             					client?.urlProtocol(self, didLoad: data)
             			}
                // If the request failed, send the error to the client
                client?.urlProtocol(self, didFailWithError: error)
            }
            // Finish loading the request
            client?.urlProtocolDidFinishLoading(self)
        })
    }
    
    /**
     Stops loading the request.
     */
    public override func stopLoading() {
        // Finish the request using the RequestInterceptor
        Self.letSee.finish(request: self.request)
    }
}
