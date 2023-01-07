//
//  LetSeeBootStrap.swift
//  
//
//  Created by Farshad Jahanmanesh on 07/01/2023.
//

import Foundation
public typealias LiveToServer = (_ request: URLRequest, _ completion: ((Data?, URLResponse?, Error?) -> Void)?) -> Void

let letSee = LetSee()
public extension LetSee {
    static var shared: LetSee {
        letSee
    }
}
