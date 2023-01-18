//
//  RawDirectoryProcessor.swift
//  
//
//  Created by Farshad Jahanmanesh on 14/01/2023.
//

import Foundation
struct RawDirectoryProcessor: DirectoryProcessing {
    typealias Information = FileURL
    let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func process(_ path: String) throws -> Dictionary<DirectoryRequestPath, [Information]> {
        let url = URL(fileURLWithPath: path)
        var files = Dictionary<DirectoryRequestPath, [FileURL]>()
        if let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey, .parentDirectoryURLKey], options: [ .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator {
                do {
                    let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey, .parentDirectoryURLKey])
                    if fileAttributes.isRegularFile!, let parentDirectory = fileAttributes.parentDirectory {
                        let directory = DirectoryRequestPath(path: parentDirectory, relativePath: "")
                        let fileURLs = (files[directory] ?? []) + [FileURL(url: fileURL) ]
                        files.updateValue(fileURLs , forKey: directory)
                    }
                } catch { print(error, fileURL) }
            }
        }
        return files
    }
}
