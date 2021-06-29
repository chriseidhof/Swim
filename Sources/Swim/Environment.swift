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

struct EnvironmentModifier<A, Content: Component>: Component & BuiltinComponent {
    init(content: Content, keyPath: WritableKeyPath<EnvironmentValues, A>, modify: @escaping (inout A) -> ()) {
        self.content = content
        self.keyPath = keyPath
        self.modify = modify
    }

    var content: Content
    var keyPath: WritableKeyPath<EnvironmentValues, A>
    var modify: (inout A) -> ()

    func render(environment: EnvironmentValues) -> Node {
        var copy = environment
        modify(&copy[keyPath: keyPath])
        return AnyBuiltin(content).render(environment: copy)
    }
    
    func readPreference<Key>(key: Key.Type) -> Key.Value? where Key : PreferenceKey {
        AnyBuiltin(content).readPreference(key: key)
    }
}

public extension Component {
    func environment<A>(keyPath: WritableKeyPath<EnvironmentValues, A>, value: A) -> some Component {
        EnvironmentModifier(content: self, keyPath: keyPath, modify: { $0 = value })
    }

    func modifyEnvironment<A>(keyPath: WritableKeyPath<EnvironmentValues, A>, modify: @escaping (inout A) -> ()) -> some Component {
        EnvironmentModifier(content: self, keyPath: keyPath, modify: modify )
    }
}

public struct EnvironmentReader<R: Component>: Component, BuiltinComponent {
    var content: (EnvironmentValues) -> R

    public init(@ComponentBuilder _ r: @escaping (EnvironmentValues) -> R) {
        self.content = r
    }
   
    func render(environment: EnvironmentValues) -> Node {
        AnyBuiltin(content(environment)).render(environment: environment)
    }
    
    func readPreference<Key>(key: Key.Type) -> Key.Value? where Key : PreferenceKey {
        // to implement this we'll need to either store off the `content(environment)` after rendering, or pass in an environment, or return the preference dict during rendering
        fatalError("TODO")
    }
}
