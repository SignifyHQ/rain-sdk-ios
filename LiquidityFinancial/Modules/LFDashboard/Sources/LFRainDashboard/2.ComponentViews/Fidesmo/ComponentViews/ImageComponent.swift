//
//  ImageComponent.swift
//  fidesmo-ios-library-example
//
//  Created by Kim Nordin on 2023-05-26.
//

import SwiftUI
import FidesmoCore

struct ImageComponent: View {
    let requirement: DataRequirement
    
    var body: some View {
        if let urlString = requirement.url, let url = URL(string: urlString) {
            AsyncImage(url: url) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .scaledToFit()
            .ifLet(requirement.label?.getFormattedText()) {
                $0.accessibilityElement() // makes it recognizable for voiceover
                    .accessibilityAddTraits(.isImage) // indicates that it is an image
                    .accessibilityLabel($1) // label for the item that voiceover will read out
            }
        } else {
            Text("Malformed Image URL")
        }
    }
}

extension ImageComponent: Component {
  var value: ComponentValue {
    return (requirement.id, "")
  }
  
  func verify() -> Bool {
    return UserInteractionValidator.validateUserInteractionTypeInput(value.1, requirement: requirement)
  }
}

extension View {
  @ViewBuilder
  func ifLet<V, Transform: View>(
    _ value: V?,
    transform: (Self, V) -> Transform
  ) -> some View {
    if let value = value {
      transform(self, value)
    } else {
      self
    }
  }
}
