//
//  String+Extension.swift
//  
//
//  Created by Farshad Macbook M1 Pro on 4/18/22.
//

import Foundation
extension String {
    static var empty: String {
        return ""
    }
}

extension Dictionary where Key == AnyHashable, Value == Any {
    func toJSON() -> String {
        return self.map({ (arg0) in
            return "{\"key\":\"\(arg0.key)\",\"value\":\"\((arg0.value as! String).replacingOccurrences(of: "\"",with: "'"))\"}"
        }).joined(separator: ",")
    }
}

extension Dictionary where Key == String, Value == String {
    func toJSON() -> String {
        return self.map({ (arg0) in
            return "{\"key\":\"\(arg0.key)\",\"value\":\"\((arg0.value ).replacingOccurrences(of: "\"",with: "'"))\"}"
        }).joined(separator: ",")
    }
}

