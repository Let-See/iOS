//
//  DirectoryRequestPath.swift
//  
//
//  Created by Farshad Jahanmanesh on 13/01/2023.
//

import Foundation

struct DirectoryRequestPath: Hashable, Comparable {
    static func < (lhs: DirectoryRequestPath, rhs: DirectoryRequestPath) -> Bool {
        lhs.path < rhs.path
    }

    let path: URL
    let relativePath: String
}
