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
        var partialResult: Dictionary<DirectoryRequestPath, [FileInformation]> = [:]
        guard let rawFiles = try? rawFileProcessor.process(path), !rawFiles.isEmpty else {
            return partialResult
        }

        var orderedItem = rawFiles.keys
            .sorted(by: {$0 < $1})
        let globalConfigs = GlobalMockDirectoryConfig.isExists(in: orderedItem.first!.path)

        // if globalConfigs is available it means that this folder should be the main folder and no file should be inside it,
        // so we can remove it from the results
        if globalConfigs != nil {
            orderedItem.removeFirst()
        }

        orderedItem.forEach { key in
            let directoryPath = key
            guard let filesInsideDirectory = rawFiles[key] else {
                return
            }
            let relativePath = self.makeRelativePath(for: directoryPath.path, relativeTo: mocksTopDirectory)
            let overriddenPath: String? = globalConfigs?.hasMap(for: relativePath)?.to
            let fileInformations: [FileInformation] = filesInsideDirectory.map { file in
                let relativePath = self.makeRelativePath(for: file.url, relativeTo: mocksTopDirectory)
                return  .init(name: file.url.lastPathComponent, filePath: file.url, relativePath: relativePath)
            }
            partialResult.updateValue(fileInformations, forKey: DirectoryRequestPath(path: directoryPath.path, relativePath: overriddenPath == nil ? relativePath : overriddenPath! + relativePath))
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

public struct GlobalMockDirectoryConfig: Decodable, Equatable {
    struct Map: Decodable, Equatable {
        let folder: String
        let to: String
        init(folder: String, to: String) {
            self.folder = folder.lowercased()
            self.to = to.lowercased()
        }
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<Self.CodingKeys> = try decoder.container(keyedBy: Self.CodingKeys.self)
            self.folder = try container.decode(String.self, forKey: Self.CodingKeys.folder).lowercased()
            self.to = try container.decode(String.self, forKey: Self.CodingKeys.to).lowercased()
        }

        public enum CodingKeys: CodingKey {
            case folder
            case to
        }
    }

    let maps: [Map]
    enum CodingKeys: CodingKey {
        case maps
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.maps = try container.decode([GlobalMockDirectoryConfig.Map].self, forKey: .maps).sorted(by: {$0.folder > $1.folder})
    }

    func hasMap(for relativePath: String) -> Map? {
        self.maps.first(where:{ relativePath.hasPrefix($0.folder)})
    }
}

extension GlobalMockDirectoryConfig {
    static let globalConfigFileName = ".ls.global.json"
    static func isExists(in path: URL) -> Self? {
        guard let data = try? Data(contentsOf: path.appendingPathComponent(GlobalMockDirectoryConfig.globalConfigFileName)) else {return nil}
        return try? JSONDecoder().decode(GlobalMockDirectoryConfig.self, from: data)
    }
}
