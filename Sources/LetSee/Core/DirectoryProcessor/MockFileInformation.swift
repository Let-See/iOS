//
//  MockFileInformation.swift
//  
//
//  Created by Farshad Jahanmanesh on 14/01/2023.
//

import Foundation
public struct MockFileInformation: Equatable, Comparable, FileInformationBasic {
    public static func < (lhs: MockFileInformation, rhs: MockFileInformation) -> Bool {
        lhs.fileInformation < rhs.fileInformation
    }

    public var url: URL {
        fileInformation.url
    }

    public enum MockStatus {
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

    public init(fileInformation: FileInformation, statusCode: Int?, delay: TimeInterval?, status: MockStatus?, displayName: String) {
        self.fileInformation = fileInformation
        self.statusCode = statusCode
        self.delay = delay
        self.status = status
        self.displayName = displayName
    }
}
