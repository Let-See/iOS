//
//  DirectoryProcessor.swift
//  
//
//  Created by Farshad Jahanmanesh on 12/01/2023.
//

import Foundation
protocol DirectoryProcessor {
    func process() throws -> Dictionary<DirectoryRequestPath, [MockFileInformation]>
}
