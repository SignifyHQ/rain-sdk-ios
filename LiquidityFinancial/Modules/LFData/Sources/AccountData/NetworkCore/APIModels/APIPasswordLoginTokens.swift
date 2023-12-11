//
//  File.swift
//  
//
//  Created by Volodymyr Davydenko on 08.12.2023.
//

import AccountDomain
import Foundation

public struct APIPasswordLoginTokens: PasswordLoginTokensEntity, Decodable {
  public var accessToken: String
  public var refreshToken: String
  public var expiresIn: String
}
