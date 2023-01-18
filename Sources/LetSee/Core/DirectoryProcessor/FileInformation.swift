//
//  FileInformation.swift
//  
//
//  Created by Farshad Jahanmanesh on 14/01/2023.
//

import Foundation
public struct FileInformation: Equatable, Comparable, FileInformationBasic {
    public var url: URL {
        self.filePath
    }

    public static func < (lhs: FileInformation, rhs: FileInformation) -> Bool {
        lhs.filePath.absoluteString < rhs.filePath.absoluteString
    }

    /// File name
    public let name: String
    /// Original path
    public let filePath: URL
    /// Relative to the top mock folder
    public let relativePath: String
}
