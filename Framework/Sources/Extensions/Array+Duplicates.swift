//  Array+Duplicates.swift

import Foundation

extension Array where Element: Hashable {
    
    var duplicates: Array {
        let groups = Dictionary(grouping: self, by: { $0 })
        let duplicateGroups = groups.filter { $1.count > 1 }
        let duplicates = Array(duplicateGroups.keys)
        return duplicates
    }
}
