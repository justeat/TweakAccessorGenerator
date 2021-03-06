//  NSNumber+ValueTypes.swift

import Foundation

public extension NSNumber {
    
    var tweakType: String {
        let encoding = String(cString: self.objCType)
        switch encoding {
        case "d":
            return "Double"
                
        case "q":
            return "Int"
            
        case "c":
            return "Bool"
            
        default:
            assert(false, "Unsupported objCType for NSNumber \(self)")
            return ""
        }
    }
}
