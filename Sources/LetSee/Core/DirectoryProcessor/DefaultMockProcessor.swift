//
//  DefaultMockProcessor.swift
//  
//
//  Created by Farshad Jahanmanesh on 14/01/2023.
//

import Foundation
struct DefaultMockProcessor: MockProcessing {
    private let _process: (String) throws -> Dictionary<DirectoryRequestPath, [MockFileInformation]>
    init<DS>(directoryProcessor: DS = MockDirectoryProcessor())
    where DS: DirectoryProcessing, DS.Information == Self.Information {
        self._process = directoryProcessor.process
    }
    func process(_ path: String) throws -> Dictionary<DirectoryRequestPath, [MockFileInformation]> {
        try _process(path)
    }

    func buildMocks(_ path: String) throws -> Dictionary<String, Set<LetSeeMock>> {
        try self.process(path)
            .reduce(into: Dictionary<String, Set<LetSeeMock>>(), { partialResult, item in
                let mocks: [LetSeeMock] = item.value.compactMap { mockFile -> LetSeeMock? in
                    guard let jsonData = try? Data(contentsOf: mockFile.fileInformation.filePath) else {return nil}
                    if mockFile.status == .success {
                        return .success(name: mockFile.displayName, response: .init(stateCode: mockFile.statusCode ?? 200, header: [:]), data: jsonData)
                    } else {
                        return .failure(name: mockFile.displayName, response: .init(rawValue: mockFile.statusCode ?? 400), data: jsonData)
                    }
                }
                partialResult.updateValue(Set(mocks), forKey: item.key.relativePath)
            })
    }
}
