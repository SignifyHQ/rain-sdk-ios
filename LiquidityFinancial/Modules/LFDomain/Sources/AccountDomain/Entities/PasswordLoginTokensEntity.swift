//
//  PasswordLoginTokensEntity.swift
//  
//
//  Created by Volodymyr Davydenko on 08.12.2023.
//

import Foundation

// sourcery: AutoMockable
public protocol PasswordLoginTokensEntity {
  var accessToken: String { get }
  var refreshToken: String { get }
  var expiresIn: String { get }
}
