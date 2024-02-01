// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import ZerohashDomain

public class MockTaxFileEntity: TaxFileEntity {

    public init() {}

    public var name: String?
    public var year: String?
    public var url: String?
    public var createdAt: String?

}

extension MockTaxFileEntity {
  public static func == (lhs: MockTaxFileEntity, rhs: MockTaxFileEntity) -> Bool {
    return lhs.name == rhs.name && lhs.year == rhs.year && lhs.url == rhs.url && lhs.createdAt == rhs.createdAt
  }
}
