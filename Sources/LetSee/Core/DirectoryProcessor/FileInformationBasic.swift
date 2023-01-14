//
//  FileInformationBasic.swift
//  
//
//  Created by Farshad Jahanmanesh on 14/01/2023.
//

import Foundation
protocol FileInformationBasic {
    var url: URL {get}
}

extension URL: Comparable, FileInformationBasic {
    var url: URL {
        self
    }

    public static func < (lhs: URL, rhs: URL) -> Bool {
        lhs.absoluteString < rhs.absoluteString
    }
}
