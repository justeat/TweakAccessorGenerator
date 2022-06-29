//  TweakValue.swift

import Foundation

public protocol TweakValue: CustomStringConvertible {}

extension Bool: TweakValue {}
extension Int: TweakValue {}
extension Float: TweakValue {}
extension Double: TweakValue {}
extension String: TweakValue {}
