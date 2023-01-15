//
//  JSONFileNameParser.swift
//  
//
//  Created by Farshad Jahanmanesh on 14/01/2023.
//

import Foundation
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
                                                  status: type == "error" ? .failure : .success,
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
