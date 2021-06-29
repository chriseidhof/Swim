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


class ComponentTests: XCTestCase {
    func testPreference() {
        struct MyComponent: Component {
            var body: some Component {
                HTML.div {
                    "Hello"
                }.preference(key: UseJavascript.self, value: true)
            }
        }
        
        XCTAssertEqual(MyComponent().readPreference(key: UseJavascript.self), true)
    }
}
