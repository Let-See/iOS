//
//  URLRequest+Extensions.swift
//  
//
//  Created by Farshad Macbook M1 Pro on 4/24/22.
//

import Foundation
public extension URLRequest {
     func addID() -> Self {
        guard self.allHTTPHeaderFields?.contains(where: {$0.key == LetSee.headerKey}) == nil else {return self}
        var request = self
        request.addValue(UUID().uuidString, forHTTPHeaderField: LetSee.headerKey)
         return request
    }
}
