//
//  FileInformation.swift
//  
//
//  Created by Farshad Jahanmanesh on 14/01/2023.
//

import Foundation
struct FileInformation: Equatable, Comparable, FileInformationBasic {
    var url: URL {
        self.filePath
    }

    static func < (lhs: FileInformation, rhs: FileInformation) -> Bool {
        lhs.filePath < rhs.filePath
    }

    /// File name
    let name: String
    /// Original path
    let filePath: URL
    /// Relative to the top mock folder
    let relativePath: String
}
