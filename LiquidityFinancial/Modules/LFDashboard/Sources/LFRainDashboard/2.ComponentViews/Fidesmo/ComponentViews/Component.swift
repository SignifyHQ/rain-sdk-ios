//
//  Component.swift
//  fidesmo-ios-library-example
//
//  Created by Kim Nordin on 2023-05-22.
//

typealias ComponentValue = (String, String)

protocol Component {
    var value: ComponentValue { get }
    func verify() -> Bool
    func asyncVerify() async -> Bool
}

// Default Protocol Conformance
extension Component {
    func verify() -> Bool {
        return true
    }

    // Asynchronous verification
    func asyncVerify() async -> Bool {
        return true
    }
}
