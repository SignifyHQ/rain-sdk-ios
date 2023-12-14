//
//  BiometricsBackupViewModel.swift
//  
//
//  Created by Volodymyr Davydenko on 08.12.2023.
//

import Foundation

public final class BiometricsBackupViewModel: ObservableObject {
  
  @Published var navigation: Navigation?
  
  func didTapBiometricsLogin() {
    
  }
  
  func didTapPasswordLogin() {
    navigation = .passwordLogin
  }
}

// MARK: - Enums

extension BiometricsBackupViewModel {
  enum Navigation {
    case passwordLogin
  }
}
