//
//  DirectoryProcessor.swift
//  
//
//  Created by Farshad Jahanmanesh on 12/01/2023.
//

import Foundation
protocol DirectoryProcessor {
    /// Analysed the directory and sub directories and creates a dictionary of them
    func process() throws -> Dictionary<DirectoryRequestPath, [MockFileInformation]>
}
