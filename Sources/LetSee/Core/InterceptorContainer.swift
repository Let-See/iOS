//
//  InterceptorContainer.swift
//  
//
//  Created by Farshad Macbook M1 Pro on 7/25/22.
//

import Foundation
public protocol InterceptorContainer {
	func addLetSeeProtocol(to config : URLSessionConfiguration) -> URLSessionConfiguration
}
