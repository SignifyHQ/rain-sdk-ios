import Foundation

public protocol AgreementDataEntity {
  var description: String? { get }
  var listDescription: [String] { get }
  var listAgreementID: [String] { get }
}
