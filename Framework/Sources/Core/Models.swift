//  Models.swift

import Foundation

struct Tweak: Equatable {
    let feature: String
    let variable: String
    let title: String
    let description: String?
    let group: String
    let valueType: String
    let propertyName: String?
}
