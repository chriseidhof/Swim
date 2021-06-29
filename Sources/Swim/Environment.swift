//
//  File.swift
//  
//
//  Created by Chris Eidhof on 29.06.21.
//

import Foundation

public protocol EnvironmentKey {
    associatedtype Value
    static var defaultValue: Value { get }
}

public struct EnvironmentValues {
    public init() { }
    
    private var userDefined: [ObjectIdentifier:Any] = [:]

    public subscript<Key: EnvironmentKey>(key: Key.Type = Key.self) -> Key.Value {
        get {
            userDefined[ObjectIdentifier(key)] as? Key.Value ?? Key.defaultValue
        }
        set {
            userDefined[ObjectIdentifier(key)] = newValue
        }
    }
}

//struct EnvironmentModifier<A, Content: Rule>: Builtin {
//    init(content: Content, keyPath: WritableKeyPath<EnvironmentValues, A>, modify: @escaping (inout A) -> ()) {
//        self.content = content
//        self.keyPath = keyPath
//        self.modify = modify
//    }
//    
//    var content: Content
//    var keyPath: WritableKeyPath<EnvironmentValues, A>
//    var modify: (inout A) -> ()
//    
//    func run(environment: EnvironmentValues) throws {
//        var copy = environment
//        modify(&copy[keyPath: keyPath])
//        try content.builtin.run(environment: copy)
//    }
//}
//
//public extension Rule {
//    func environment<A>(keyPath: WritableKeyPath<EnvironmentValues, A>, value: A) -> some Rule {
//        EnvironmentModifier(content: self, keyPath: keyPath, modify: { $0 = value })
//    }
//    
//    func modifyEnvironment<A>(keyPath: WritableKeyPath<EnvironmentValues, A>, modify: @escaping (inout A) -> ()) -> some Rule {
//        EnvironmentModifier(content: self, keyPath: keyPath, modify: modify )
//    }
//}
//
//// Convenience
//extension Rule {
//    public func outputPath(_ string: String) -> some Rule {
//        modifyEnvironment(keyPath: \.output, modify: { path in
//            path.appendPathComponent(string)
//        })
//    }
//}
//
//extension EnvironmentValues {
//    public func write(_ data: Data) throws {
//        let name = output
//        let directory = name.deletingLastPathComponent()
//        var isDirectory: ObjCBool = false
//        let dirExists = fileManager.fileExists(atPath: directory.path, isDirectory: &isDirectory)
//        if !dirExists || !isDirectory.boolValue {
//            try? fileManager.removeItem(at: directory)
//            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
//        }
//        try data.write(to: name)
//    }
//}
//
//public struct EnvironmentReader<R: Rule>: Builtin {
//    var content: (EnvironmentValues) -> R
//    
//    public init(@RuleBuilder _ r: @escaping (EnvironmentValues) -> R) {
//        self.content = r
//    }
//    public func run(environment: EnvironmentValues) throws {
//        try content(environment)
//            .builtin
//            .run(environment: environment)
//    }
//}
