//
//  BiometricsBackupView.swift
//  
//
//  Created by Volodymyr Davydenko on 08.12.2023.
//

import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable

public struct BiometricsBackupView: View {
  @StateObject
  private var viewModel = BiometricsBackupViewModel()
  
  public init() {}
  
  public var body: some View {
    content
      .background(Colors.background.swiftUIColor)
      .navigationLink(
        item: $viewModel.navigation,
        destination: { navigation in
          switch navigation {
          case .passwordLogin:
            EnterPasswordView()
          }
        }
      )
      .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension BiometricsBackupView {
  var content: some View {
    VStack(alignment: .center) {
      Spacer()
      
      GenImages.CommonImages.imgFaceID.swiftUIImage
        .foregroundColor(Colors.label.swiftUIColor)
      
      Spacer()
      
      buttonGroup
    }
    .padding([.horizontal, .bottom], 30)
  }
  
  var buttonGroup: some View {
    VStack(spacing: 12) {
      FullSizeButton(
        title: LFLocalizable.Authentication.BiometricsBackup.BiomericsButton.title,
        isDisable: false,
        type: .primary
      ) {
        viewModel.didTapBiometricsLogin()
      }
      
      FullSizeButton(
        title: LFLocalizable.Authentication.BiometricsBackup.PasswordButton.title,
        isDisable: false,
        type: .secondary
      ) {
        viewModel.didTapPasswordLogin()
      }
    }
  }
}

