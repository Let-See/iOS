//
//  DirectoryProcessor.swift
//  
//
//  Created by Farshad Jahanmanesh on 12/01/2023.
//

import Foundation
protocol DirectoryProcessor {
    func processMocks(in directory: String) throws -> Dictionary<DirectoryRequestPath, [MockFileInformation]>
}
