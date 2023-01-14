//
//  MockDirectoryProcessor.swift
//  
//
//  Created by Farshad Jahanmanesh on 13/01/2023.
//

import Foundation

struct MockDirectoryProcessor<DS>: DirectoryProcessing where DS: DirectoryProcessing, DS.Information == FileInformation {
    typealias Information = MockFileInformation
    let fileProcessor: DS
    let fileNameParser: FileNameParsing
    init(fileProcessor: DS = FileDirectoryProcessor(),
         fileNameParser: FileNameParsing = JSONFileNameParser()) {
        self.fileProcessor = fileProcessor
        self.fileNameParser = fileNameParser
    }

    func process(_ path: String) throws -> Dictionary<DirectoryRequestPath, [MockFileInformation]> {
        guard let files = try? self.fileProcessor.process(path) else {
            return [:]
        }
        return files.reduce(into: [:]) { partialResult, item in
            let mocks = item.value.compactMap { file in
                try? self.fileNameParser.parse(file)
            }
            partialResult.updateValue(mocks, forKey: item.key)
        }
    }
}
