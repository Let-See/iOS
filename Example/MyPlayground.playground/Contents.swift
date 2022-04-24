import Foundation

protocol Item {
    var category: String { get }
    var group: String { get }
}


class ItemMatcher {
    let items: [Item]
    init(items: [Item]) {
        self.items = items
    }

    // Write your solution in Swift 4 in this method
    func itemMatching(group: String, category: String) -> Item? {
        if group == "*", category == "*" {
            return items.first
        }
        
        if group == "*" {
            return
        }
        
        let acceptableItem =  [category: group, "*": "*", category: "*", "*": group]
        var result: (category:String, group: String)
        for item in items {
            if category ==
        }
        return
    }

}


/// Code executing the test cases, do not edit
struct TestItem: Item {
    let category: String
    let group: String
}

public func solution(_ S : inout String, _ T : inout String) -> String {
    let allItems = S.split(separator: "/").map { (line) -> TestItem in
        let array = line.split(separator: ",")
        return TestItem(category: String(array[0]), group: String(array[1]))
    }
    let searchArray = T.split(separator: ",")
    let category = String(searchArray[0])
    let group = String(searchArray[1])
    
    let matcher = ItemMatcher(items: allItems)
    let result = matcher.itemMatching(group: group, category: category)
    
    if let result = result {
        return result.category + "," + result.group
    } else {
        return ""
    }
}
