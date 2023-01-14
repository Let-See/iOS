//
//  FileDirectoryProcessor.swift
//  
//
//  Created by Farshad Jahanmanesh on 14/01/2023.
//

import Foundation
struct FileDirectoryProcessor: DirectoryProcessing {
    typealias Information = FileInformation
    let rawFileProcessor: any DirectoryProcessing
    init(rawFileProcessor: any DirectoryProcessing = RawDirectoryProcessor()) {
        self.rawFileProcessor = rawFileProcessor
    }

    func process(_ path: String) throws -> Dictionary<DirectoryRequestPath, [Information]> {
        let mocksTopDirectory = path
        var configFile: PathConfig?
        var partialResult: Dictionary<DirectoryRequestPath, [FileInformation]> = [:]
        guard let rawFiles = try? rawFileProcessor.process(path) else {
            return partialResult
        }

        let orderedItem = rawFiles.keys
            .sorted(by: {$0 < $1})

        orderedItem.forEach { key in
            let directoryPath = key
            guard let filesInsideDirectory = rawFiles[key] else {
                return
            }
            if let config = filesInsideDirectory.first(where: {$0.url.lastPathComponent == LetSee.configsFileName}) {
                configFile = parseConfigFile(config.url)
            } else {
                configFile = nil
            }
            let relativePath = self.makeRelativePath(for: directoryPath.path, relativeTo: mocksTopDirectory)
            let fileInformations: [FileInformation] = filesInsideDirectory.map { file in
                let relativePath = self.makeRelativePath(for: file.url, relativeTo: mocksTopDirectory)
                return  .init(name: file.url.lastPathComponent, filePath: file.url, relativePath: relativePath)
            }
            partialResult.updateValue(fileInformations, forKey: DirectoryRequestPath(path: directoryPath.path, relativePath: configFile == nil ? relativePath : configFile!.path + relativePath))
        }
        return partialResult
    }

    func makeRelativePath(for path: URL, relativeTo: String) -> String {
        var result = path.absoluteString
        if path.isFileURL {
            result.removeFirst(7)
        }
        return result.replacingOccurrences(of: relativeTo, with: "")
            .lowercased()
    }

    func parseConfigFile(_ configsPath: URL) -> PathConfig? {
        guard let jsonData = try? Data(contentsOf: configsPath),
              let configs = try? JSONDecoder().decode(PathConfig.self, from: jsonData) else {
            return nil
        }
        return configs
    }
}
