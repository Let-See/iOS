//
//  Utility.swift
//  
//
//  Created by Farshad Jahanmanesh on 07/01/2023.
//

import Foundation

/// Adds @LETSEE>  at the beginning of the print statement
///
/// - Parameters:
///    - message: the print string
@discardableResult
func print(_ message: String) -> String {
    let printableMessage = "@LETSEE > \(message)"
    Swift.print(printableMessage)
    return printableMessage
}
