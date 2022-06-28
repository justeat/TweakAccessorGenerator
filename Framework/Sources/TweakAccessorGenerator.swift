//
//  TweakAccessorGenerator.swift
//  Copyright © 2021 Just Eat Takeaway. All rights reserved.
//

import Foundation
import ArgumentParser

@main
struct TweakAccessorGenerator: ParsableCommand {
    
    @Option(name: .shortAndLong, help: "The path to the tweaks file.")
    var localTweaksFilePath: String
    
    @Option(name: .shortAndLong, help: "The path to the output folder.")
    var outputFolder: String
    
    @Option(name: .shortAndLong, help: "The name of the accessor class generated.")
    var accessorClassName: String
    
    private var tweaksFilename: String {
        let url = URL(fileURLWithPath: localTweaksFilePath)
        return String(url.lastPathComponent.split(separator: ".").first!)
    }
    
    func run() throws {
        let codeGenerator = CodeGenerator()
        let tweakLoader = TweakLoader()
        let tweaks = try tweakLoader.load(localTweaksFilePath)
        
        let constantFileUrl = try writeConstantsFile(codeGenerator: codeGenerator,
                                                     tweaks: tweaks,
                                                     outputFolder: outputFolder,
                                                     accessorClassName: accessorClassName)
        print("Constants file generated at \(constantFileUrl.path).")
        
        let accessorFileUrl = try writeAccessorFile(codeGenerator: codeGenerator,
                                                    tweaks: tweaks,
                                                    outputFolder: outputFolder,
                                                    accessorClassName: accessorClassName)
        print("Accessor file generated at \(accessorFileUrl.path).")
    }
}

extension TweakAccessorGenerator {
    
    private func writeConstantsFile(codeGenerator: CodeGenerator,
                                    tweaks: [Tweak],
                                    outputFolder: String,
                                    accessorClassName: String) throws -> URL {
        let fileName = "\(accessorClassName)+Constants.swift"
        let url: URL = URL(fileURLWithPath: outputFolder).appendingPathComponent(fileName)
        let constants = codeGenerator.generateConstantsFileContent(tweaks: tweaks,
                                                                   accessorClassName: accessorClassName)
        let existingConstants = try? String(contentsOf: url, encoding: .utf8)
        
        switch (existingConstants, constants) {
        case (.none, let content):
            try content.write(to: url, atomically: true, encoding: .utf8)
        case (.some(let existingContent), let content) where existingContent != content:
            try content.write(to: url, atomically: true, encoding: .utf8)
        case (.some, _):
            break
        }
        
        return url
    }
    
    private func writeAccessorFile(codeGenerator: CodeGenerator,
                                   tweaks: [Tweak],
                                   outputFolder: String,
                                   accessorClassName: String) throws -> URL {
        let fileName = "\(accessorClassName).swift"
        let url: URL = URL(fileURLWithPath: outputFolder).appendingPathComponent(fileName)
        let accessor = codeGenerator.generateAccessorFileContent(tweaksFilename: tweaksFilename,
                                                                 tweaks: tweaks,
                                                                 accessorClassName: accessorClassName)
        let existingAccessor = try? String(contentsOf: url, encoding: .utf8)
        
        switch (existingAccessor, accessor) {
        case (.none, let accessor):
            try accessor.write(to: url, atomically: true, encoding: .utf8)
        case (.some(let existingAccessor), let accessor) where existingAccessor != accessor:
            try accessor.write(to: url, atomically: true, encoding: .utf8)
        case (.some, _):
            break
        }
        
        return url
    }
}
