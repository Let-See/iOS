//
//  DirectoryRequestPath.swift
//  
//
//  Created by Farshad Jahanmanesh on 13/01/2023.
//

import Foundation

public struct DirectoryRequestPath: Hashable, Comparable {
    public static func < (lhs: DirectoryRequestPath, rhs: DirectoryRequestPath) -> Bool {
        lhs.path.absoluteString < rhs.path.absoluteString
    }

    let path: URL
    let relativePath: String
}
