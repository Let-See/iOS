//
//  DirectoryProcessing.swift
//  
//
//  Created by Farshad Jahanmanesh on 14/01/2023.
//

import Foundation
public protocol DirectoryProcessing {
    associatedtype Information: FileInformationBasic, Comparable
    /// Analysed the directory and sub directories and creates a dictionary of them
    func process(_ path: String) throws -> Dictionary<DirectoryRequestPath, [Information]>
}
