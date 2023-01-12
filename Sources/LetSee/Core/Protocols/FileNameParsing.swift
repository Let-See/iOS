//
//  FileNameParsing.swift
//  
//
//  Created by Farshad Jahanmanesh on 11/01/2023.
//

import Foundation
struct FileInformation: Equatable {
    /// File name
    let name: String
    /// Original path
    let filePath: URL
    /// Relative to the top mock folder
    let relativePath: String
//    /// When there is a config file in the parent director, some times it specifies the path itself for all its childs
//    let overriddenPath: String?
}

struct MockFileInformation: Equatable {
    enum MockStatus {
        case success
        case failure
    }
    /// Information about the raw file
    let fileInformation: FileInformation
    /// Status code
    let statusCode: Int?
    /// Optional delay option, it specifies a delay in millisecond
    let delay: TimeInterval?
    /// Status: the `statusCode` has a higher priority so if `statusCode` is not nil, the value of this variable will be sets based on that, **200-299 indicates success status, and any thing else means failure**
    let status: MockStatus?

    let displayName: String
}
protocol FileNameParsing {
    func parse(_ filePath: FileInformation) throws -> MockFileInformation
}

enum FileProcessError: Error {
    case fileNameIsNotValid
}
//
struct JSONFileNameParser: FileNameParsing {
    func parse(_ file: FileInformation) throws -> MockFileInformation {
        let components = file.name.components(separatedBy: "_")
        guard components.count >= 2 else {
            throw FileProcessError.fileNameIsNotValid
        }
        let firstComponentIndex = 0
        let lastComponentIndex = components.count - 1
        let fileName = components.last!.components(separatedBy: ".")
        let name = fileName.first!.capitalizingFirstLetter()
        let type = components.first!
        
        var statusCode: Int?
        var delay: Double?

        if components.count > 2 {
            let fileNameComponents = Array(components[firstComponentIndex+1..<lastComponentIndex])
            var parseDelay: (String) -> Double? = { delay in
                return Double(delay.dropLast(2))
            }

            if let status = fileNameComponents[exist: 0]{
                if status.hasSuffix("ms") {
                    delay = parseDelay(status)
                } else {
                    statusCode = Int(fileNameComponents[exist: 0] ?? "")
                }
            }

            if let delayString = fileNameComponents[exist: 1] {
                delay = parseDelay(delayString)
            }
        }
        let fileInformation = MockFileInformation(fileInformation: file,
                                                  statusCode: statusCode,
                                                  delay: delay,
                                                  status: type == "success" ? .success : .failure,
                                                  displayName: name)
        return fileInformation
    }
}

fileprivate extension Collection where Indices.Iterator.Element == Index {
    subscript (exist index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

fileprivate extension String {
    func capitalizingFirstLetter() -> String {
      return prefix(1).uppercased() + self.dropFirst()
    }

    mutating func capitalizeFirstLetter() {
      self = self.capitalizingFirstLetter()
    }
}
