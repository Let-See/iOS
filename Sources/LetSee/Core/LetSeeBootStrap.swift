//
//  LetSeeBootStrap.swift
//  
//
//  Created by Farshad Jahanmanesh on 07/01/2023.
//

import Foundation

let letSee = LetSee()
public extension LetSee {
    static var shared: LetSee {
        letSee
    }
}
