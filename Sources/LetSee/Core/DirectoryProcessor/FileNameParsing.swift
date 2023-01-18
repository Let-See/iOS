//
//  FileNameParsing.swift
//  
//
//  Created by Farshad Jahanmanesh on 11/01/2023.
//

import Foundation
public protocol FileNameParsing {
    func parse(_ filePath: FileInformation) throws -> MockFileInformation
}
