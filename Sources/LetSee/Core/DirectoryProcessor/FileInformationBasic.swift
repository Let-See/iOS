//
//  FileInformationBasic.swift
//  
//
//  Created by Farshad Jahanmanesh on 14/01/2023.
//

import Foundation
public protocol FileInformationBasic {
    var url: URL {get}
}

struct FileURL: Comparable, FileInformationBasic {
    var url: URL
    init(url: URL) {
        self.url = url
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.url.absoluteString < rhs.url.absoluteString
    }
}
