//
//  StaticTextComponent.swift
//  fidesmo-ios-library-example
//
//  Created by Kim Nordin on 2023-05-24.
//

import SwiftUI
import FidesmoCore

struct StaticTextComponent: View {
    let requirement: DataRequirement
    
    var body: some View {
        Text(.init(requirement.label?.getFormattedText() ?? ""))
            .frame(maxWidth: .infinity)
    }
}

extension StaticTextComponent: Component {
    var value: ComponentValue {
        return (requirement.id, "")
    }

    func verify() -> Bool {
        return UserInteractionValidator.validateUserInteractionTypeInput(value.1, requirement: requirement)
    }
}

