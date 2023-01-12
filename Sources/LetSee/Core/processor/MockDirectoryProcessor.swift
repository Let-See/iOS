//
//  MockDirectoryProcessor.swift
//  
//
//  Created by Farshad Jahanmanesh on 13/01/2023.
//

import Foundation
struct MockDirectoryProcessor: DirectoryProcessor {
    let fileManager: FileManager
    let mocksTopDirectory: String
    let fileNameParser: FileNameParsing
    init(fileManager: FileManager = .default, directoryToProcess directory: String, fileNameParser: FileNameParsing = JSONFileNameParser()) {
        self.fileManager = fileManager
        self.mocksTopDirectory = directory
        self.fileNameParser = fileNameParser
    }

    func process() throws -> Dictionary<DirectoryRequestPath, [MockFileInformation]> {
        let rawFiles = getAllChild(in: mocksTopDirectory)
        let fileInformations = map(files: rawFiles)
        let mocks = makeMock(for: fileInformations)
        return mocks
    }

    func getAllChild(in path: String) -> Dictionary<URL, [URL]> {
        let url = URL(fileURLWithPath: path)
        var files = Dictionary<URL, [URL]>()
        if let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey, .parentDirectoryURLKey], options: [ .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator {
                do {
                    let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey, .parentDirectoryURLKey])
                    if fileAttributes.isRegularFile!, let parentDirectory = fileAttributes.parentDirectory {
                        let fileURLs = (files[parentDirectory] ?? []) + [fileURL]
                        files.updateValue(fileURLs , forKey: parentDirectory)
                    }
                } catch { print(error, fileURL) }
            }
        }
        return files
    }

    func map(files: Dictionary<URL, [URL]>) -> Dictionary<DirectoryRequestPath, [FileInformation]> {
        var configFile: PathConfig?
        var partialResult: Dictionary<DirectoryRequestPath, [FileInformation]> = [:]
        let orderedItem = files.keys
            .sorted(by: {$0.absoluteString < $1.absoluteString})

        orderedItem.forEach { key in
            let directoryPath = key
            guard let filesInsideDirectory = files[key] else {
                return
            }
            if let config = filesInsideDirectory.first(where: {$0.lastPathComponent == LetSee.configsFileName}) {
                configFile = parseConfigFile(config)
            }
            let relativePath = self.makeRelativePath(for: directoryPath, relativeTo: self.mocksTopDirectory)
            let fileInformations: [FileInformation] = filesInsideDirectory.map { url in
                let relativePath = self.makeRelativePath(for: url, relativeTo: self.mocksTopDirectory)
                return  .init(name: url.lastPathComponent, filePath: url, relativePath: relativePath)
            }
            partialResult.updateValue(fileInformations, forKey: DirectoryRequestPath(path: directoryPath, relativePath: configFile == nil ? relativePath : configFile!.path + relativePath))
        }
        return partialResult
    }

    func makeMock(for files: Dictionary<DirectoryRequestPath, [FileInformation]>) -> Dictionary<DirectoryRequestPath, [MockFileInformation]> {
        files.reduce(into: [:]) { partialResult, item in
            let mocks = item.value.compactMap { file in
                try? self.fileNameParser.parse(file)
            }
            partialResult.updateValue(mocks, forKey: item.key)
        }
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
