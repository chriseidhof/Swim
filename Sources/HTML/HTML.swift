import Foundation

public enum Node: CustomDebugStringConvertible {
    case comment(String)
    case tag(name: String, attributes: [String: String], children: [Node])
    case text(String)

    var children: [Node] {
        switch self {
        case let .tag(_, _, children):
            return children
        case .comment, .text:
            return []
        }
    }

    func serialize(buffer: inout String, indentationLevel: Int = 0) {
        func pad(string: String) -> String {
            return String(repeating: " " as Character, count: 2 * indentationLevel) + string + "\n"
        }

        switch self {
        case let .comment(value):
            buffer += "<!-- \(value) -->"
        case let .tag(name, attributes, children):
            let serializedAttributes = attributes
                .map { key, value in "\(key)=\"\(value)\"" }
                .joined(separator: " ")

            if children.isEmpty {
                if serializedAttributes.isEmpty {
                    buffer += pad(string: "<\(name)/>")
                } else {
                    buffer += pad(string: "<\(name) \(serializedAttributes) />")
                }
            } else {
                if serializedAttributes.isEmpty {
                    buffer += pad(string: "<\(name)>")
                } else {
                    buffer += pad(string: "<\(name) \(serializedAttributes)>")
                }

                for child in children {
                    child.serialize(buffer: &buffer, indentationLevel: indentationLevel + 1)
                }

                buffer += pad(string: "</\(name)>")
            }
        case let .text(value):
            buffer += pad(string: value)
        }
    }

    public var debugDescription: String {
        var buffer = ""

        serialize(buffer: &buffer)

        return buffer
    }
}

extension Array: ExpressibleByUnicodeScalarLiteral where Element == Node {
    public typealias UnicodeScalarLiteralType = String
}

extension Array: ExpressibleByExtendedGraphemeClusterLiteral where Element == Node {
    public typealias ExtendedGraphemeClusterLiteralType = String
}

extension Array: ExpressibleByStringLiteral where Element == Node {
    public typealias StringLiteralType = String

    public init(stringLiteral value: String) {
        self = [ .text(value) ]
    }
}

@_functionBuilder
public struct NodeBuilder {
    public static func buildBlock(_ content: String) -> [Node] {
        return [ .text(content) ]
    }

    public static func buildBlock(_ content: String...) -> [Node] {
        return content.flatMap(buildBlock)
    }

    public static func buildBlock(_ content: Node) -> [Node] {
        return [ content ]
    }

    public static func buildBlock(_ content: [Node]...) -> [Node] {
        return content.flatMap { $0 }
    }

    public static func buildIf(_ content: [Node]?) -> [Node] {
        if let content = content { return content }

        return []
    }

    public static func buildEither(first: [Node]) -> [Node] {
        return first
    }

    public static func buildEither(second: [Node]) -> [Node] {
        return second
    }
}