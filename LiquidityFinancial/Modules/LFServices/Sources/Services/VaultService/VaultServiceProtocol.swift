import Foundation
import LFUtilities
import VGSCollectSDK

public protocol VaultServiceProtocol {
  var vgsCollect: VGSCollect { get }
  func addDebitCardToVault(debitCardToken: DebitCardToken, debitCardData: DebitCardModel) async throws
  func addDebitCardToVault(
    debitCardToken: DebitCardToken,
    debitCardData: DebitCardModel,
    completion: @escaping (Result<Void, VaultError>) -> Void
  )
  
  init(vgsID: String, vgsENV: String)
}
