//
//  File.swift
//  
//
//  Created by Chris Eidhof on 29.06.21.
//

import Foundation
import Swim
import XCTest
import HTML

struct UseJavascript: PreferenceKey {
    static var defaultValue = false
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

struct Greeting: EnvironmentKey {
    static var defaultValue: String = "Hello"
}

extension EnvironmentValues {
    var greeting: Greeting.Value {
        get { self[Greeting.self] }
        set { self[Greeting.self] = newValue }
    }
}


class ComponentTests: XCTestCase {
    func testPreference() {
        struct MyComponent: Component {
            var body: some Component {
                EnvironmentReader { env in
                    HTML.div {
                        %Node.text(env.greeting)%
                    }
                }.preference(key: UseJavascript.self, value: true)
               
            }
        }
        
        struct Sample: Component {
            @ComponentBuilder var body: some Component {
                HTML.p { }
                MyComponent()
            }
        }
        
        let result = Sample()
            .environment(keyPath: \.greeting, value: "Hi")
        XCTAssertEqual(result.readPreference(key: UseJavascript.self), true)
        let expected =
        """
        
        <p>
        </p>
        <div>Hi</div>
        """
        XCTAssertEqual(result.render().rendered, expected)
    }
}
