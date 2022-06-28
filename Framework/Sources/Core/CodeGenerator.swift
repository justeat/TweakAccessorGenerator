//  CodeGenerator.swift

import Foundation

class CodeGenerator {
    
    private let featuresConst = "Features"
    private let variablesConst = "Variables"
    
    private let featureConstantsConst = "<FEATURE_CONSTANTS_CONST>"
    private let variableConstantsConst = "<VARIABLE_CONSTANTS_CONST>"
    private let classContentConst = "<CLASS_CONTENT>"
    private let tweakManagerConst = "<TWEAK_MANAGER_CONTENT>"
}

extension CodeGenerator {
    
    func generateConstantsFileContent(tweaks: [Tweak],
                                      accessorClassName: String) -> String {
        let template = self.constantsTemplate(with: accessorClassName)
        let featureConstants = self.featureConstantsCodeBlock(with: tweaks)
        let variableConstants = self.variableConstantsCodeBlock(with: tweaks)
        
        let content = template
            .replacingOccurrences(of: featureConstantsConst, with: featureConstants)
            .replacingOccurrences(of: variableConstantsConst, with: variableConstants)
            .trimmingCharacters(in: .whitespacesAndNewlines) + "\n"
        return content
    }
    
    func generateAccessorFileContent(tweaksFilename: String,
                                     tweaks: [Tweak],
                                     accessorClassName: String) -> String {
        let template = self.accessorTemplate(with: accessorClassName)
        let tweakManager = self.tweakManagerCodeBlock()
        let classContent = self.classContent(with: tweaks)
        
        let content = template
            .replacingOccurrences(of: tweakManagerConst, with: tweakManager)
            .replacingOccurrences(of: classContentConst, with: classContent)
            .trimmingCharacters(in: .whitespacesAndNewlines) + "\n"
        return content
    }
    
    func constantsTemplate(with className: String) -> String {
        """
        //  \(className)+Constants.swift

        ///  Generated by TweakAccessorGenerator
        
        import Foundation
        
        extension \(className) {
        
        \(featureConstantsConst)
        
        \(variableConstantsConst)
        }
        """
    }
    
    private func accessorTemplate(with className: String) -> String {
        """
        //  \(className).swift

        ///  Generated by TweakAccessorGenerator
        
        import Foundation
        import JustTweak
        
        class \(className) {

        \(tweakManagerConst)
        
        \(classContentConst)
        }
        """
    }
    
    private func featureConstantsCodeBlock(with tweaks: [Tweak]) -> String {
        var features = Set<FeatureKey>()
        for tweak in tweaks {
            features.insert(tweak.feature)
        }
        let content: [String] = features.map {
            """
                    static let \($0.camelCased()) = "\($0)"
            """
        }
        return """
            struct \(featuresConst) {
        \(content.sorted().joined(separator: "\n"))
            }
        """
    }
    
    private func variableConstantsCodeBlock(with tweaks: [Tweak]) -> String {
        var variables = Set<VariableKey>()
        for tweak in tweaks {
            variables.insert(tweak.variable)
        }
        let content: [String] = variables.map {
            """
                    static let \($0.camelCased()) = "\($0)"
            """
        }
        return """
            struct \(variablesConst) {
        \(content.sorted().joined(separator: "\n"))
            }
        """
    }
    
    private func tweakManagerCodeBlock() -> String {
        """
            private(set) var tweakManager: TweakManager

            init(with tweakManager: TweakManager) {
                self.tweakManager = tweakManager
            }
        """
    }
    
    private func classContent(with tweaks: [Tweak]) -> String {
        var content: Set<String> = []
        tweaks.forEach {
            content.insert(tweakComputedProperty(for: $0))
        }
        return content.sorted().joined(separator: "\n\n")
    }
    
    private func tweakPropertyWrapper(for tweak: Tweak) -> String {
        let propertyName = tweak.propertyName ?? tweak.variable.camelCased()
        return """
            @TweakProperty(feature: \(featuresConst).\(tweak.feature.camelCased()),
                           variable: \(variablesConst).\(tweak.variable.camelCased()),
                           tweakManager: tweakManager)
            var \(propertyName): \(tweak.valueType)
        """
    }
    
    private func tweakComputedProperty(for tweak: Tweak) -> String {
        let propertyName = tweak.propertyName ?? tweak.variable.camelCased()
        let feature = "\(featuresConst).\(tweak.feature.camelCased())"
        let variable = "\(variablesConst).\(tweak.variable.camelCased())"
        let castProperty = try! self.castProperty(for: tweak.valueType)
        let defaultValue = try! self.defaultValue(for: tweak.valueType)
        return """
            var \(propertyName): \(tweak.valueType) {
                get { (try? tweakManager.tweakWith(feature: \(feature), variable: \(variable)))?.\(castProperty) ?? \(defaultValue) }
                set { tweakManager.set(newValue, feature: \(feature), variable: \(variable)) }
            }
        """
    }
    
    private func castProperty(for valueType: String) throws -> String {
        switch valueType {
        case "String":
            return "stringValue"
        case "Bool":
            return "boolValue"
        case "Double":
            return "doubleValue"
        case "Int":
            return "intValue"
        default:
            throw "Unsupported value type '\(valueType)'"
        }
    }
    
    private func defaultValue(for valueType: String) throws -> String {
        switch valueType {
        case "String":
            return "\"\""
        case "Bool":
            return "false"
        case "Double":
            return "0.0"
        case "Int":
            return "0"
        default:
            throw "Unsupported value type '\(valueType)'"
        }
    }
    
    private func formatCustomTweakProviderSetupCode(_ setupCode: String) -> String {
        setupCode.split(separator: "\n")
            .map { "        " + $0 }
            .joined(separator: "\n")
    }
}
