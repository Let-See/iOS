//
//  MockProcessing.swift
//  
//
//  Created by Farshad Jahanmanesh on 14/01/2023.
//

import Foundation
protocol MockProcessing: DirectoryProcessing where Information == MockFileInformation {
    func process(_ path: String) throws -> Dictionary<DirectoryRequestPath, [Information]>
    func buildMocks(_ path: String) throws -> Dictionary<String, Set<LetSeeMock>>
}
