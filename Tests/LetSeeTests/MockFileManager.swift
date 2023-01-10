//
//  MockFileManager.swift
//  
//
//  Created by Farshad Jahanmanesh on 08/01/2023.
//

import Foundation
class MockFileManager: FileManager {
    func recursivelyFindAllFiles(for path: String, ofType filterType: String? = nil) -> [URL] {
        let url = URL(fileURLWithPath: path)
        var files = [URL]()
        if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator {
                do {
                    let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey])
                    if fileAttributes.isRegularFile! {
                        files.append(fileURL)
                    }
                } catch {
                    print(error, fileURL)
                }
            }
        }
        if let filterType {
            files = files.filter{$0.pathExtension == filterType}
        }
        return files
    }
}

