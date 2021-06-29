//
//  File.swift
//  
//
//  Created by Chris Eidhof on 29.06.21.
//

import Foundation

@resultBuilder
public enum ComponentBuilder {
    public static func buildIf<Content>(_ content: Content?) -> Content? where Content : Component {
        content
    }
    
    public static func buildBlock<Content>(_ content: Content) -> Content where Content : Component {
        content
    }

    public static func buildBlock<C0, C1>(_ c0: C0, _ c1: C1) -> Pair<C0, C1> where C0 : Component, C1 : Component {
        return Pair(c0, c1)
    }
}

extension Never: Component {
    public typealias Result = Never
    public var body: Never { fatalError("This should never happen") }
}

public protocol Component {
    associatedtype Result: Component
    var body: Result { get }
}

public protocol PreferenceKey {
     associatedtype Value: Hashable
     static var defaultValue: Value { get }
     static func reduce(value: inout Value, nextValue: () -> Value)
 }

struct AnyBuiltin: BuiltinComponent {
    var b: BuiltinComponent
    init<C: Component>(_ component: C) {
        if let builtin = component as? BuiltinComponent {
            b = builtin
        } else {
            b = AnyBuiltin(component.body)
        }
    }
    
    func readPreference<Key>(key: Key.Type) -> Key.Value? where Key : PreferenceKey {
        b.readPreference(key: key)
    }
    func render() -> Node {
        b.render()
    }
}

// A private protocol
protocol BuiltinComponent {
    func render() -> Node
    func readPreference<Key: PreferenceKey>(key: Key.Type) -> Key.Value?
}

extension BuiltinComponent {
    public typealias Result = Never
    public var body: Never { fatalError("This should never happen") }
}

struct PreferenceWriter<C: Component, P: PreferenceKey>: Component, BuiltinComponent {
    var child: C
    var value: P.Value
    
    func render() -> Node {
        AnyBuiltin(child).render()
    }
    
    func readPreference<Key>(key: Key.Type) -> Key.Value? where Key : PreferenceKey {
        if key == P.self {
            return (value as! Key.Value)
        } else {
            return AnyBuiltin(child).readPreference(key: key)
        }
    }
}

extension Component {
    public func preference<P: PreferenceKey>(key: P.Type = P.self, value: P.Value) -> some Component {
        PreferenceWriter<Self, P>(child: self, value: value)
    }
    
    public func readPreference<P: PreferenceKey>(key: P.Type = P.self) -> P.Value {
        return AnyBuiltin(self).readPreference(key: key) ?? P.defaultValue
    }
}

extension Node: Component & BuiltinComponent {
    func readPreference<Key>(key: Key.Type) -> Key.Value? where Key : PreferenceKey {
        return nil
    }
    func render() -> Node {
        self
    }
}

public struct Pair<L, R>: Component, BuiltinComponent where L: Component, R: Component {
    var value: (L, R)
    init(_ l: L, _ r: R) {
        self.value = (l,r)
    }
    
//    public func run(environment: EnvironmentValues) throws {
//        try value.0.builtin.run(environment: environment)
//        try value.1.builtin.run(environment: environment)
//    }
    @NodeBuilder func render() -> Node {
        AnyBuiltin(value.0).render()
        AnyBuiltin(value.1).render()
    }
    
    func readPreference<Key>(key: Key.Type) -> Key.Value? where Key : PreferenceKey {
        if var x = AnyBuiltin(value.0).readPreference(key: key) {
            if let y = AnyBuiltin(value.1).readPreference(key: key) {
                Key.reduce(value: &x, nextValue: { y })
            }
            return x
        } else {
            return AnyBuiltin(value.1).readPreference(key: key)
        }
    }
}

extension Component {
    public var rendered: Node {
        AnyBuiltin(self).render()
    }
}
