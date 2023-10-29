import Foundation
import VGSCollectSDK

// MARK: - VaultService
public class VaultService: VaultServiceProtocol { 
  public let vgsCollect: VGSCollect

  public required init(vgsID: String, vgsENV: String) {
    self.vgsCollect = VGSCollect(id: vgsID, environment: vgsENV)
  }

  public func addDebitCardToVault(debitCardToken: DebitCardToken, debitCardData: DebitCardModel) async throws {
    try await withCheckedThrowingContinuation { continuation in
      addDebitCardToVault(debitCardToken: debitCardToken, debitCardData: debitCardData) { result in
        continuation.resume(with: result)
      }
    }
  }
  
  @available(*, renamed: "addDebitCardToVault(debitCardData:)")
  public func addDebitCardToVault(
    debitCardToken: DebitCardToken,
    debitCardData: DebitCardModel,
    completion: @escaping (Result<Void, VaultError>) -> Void
  ) {
    let vgsDebitCardModel = VGSDebitCardModel(debitCard: debitCardData)
    
    let path = getVGSPath(solidContactID: debitCardToken.solidContactId)
    vgsCollect.customHeaders = ["sd-debitcard-token": debitCardToken.linkToken]
    
    guard let param = vgsDebitCardModel.dictionary else {
      completion(.failure(.unknownError(message: "failed to encode debit card data")))
      return
    }
    
    vgsCollect.sendData(
      path: path,
      method: VGSCollectHTTPMethod.patch,
      extraData: param
    ) { [weak self] response in
      guard let self = self else { return }
      self.process(response: response, completion: completion)
    }
  }
}

// MARK: - Private Functions
private extension VaultService {
  func getVGSPath(solidContactID: String) -> String {
    return "/v1/contact/\(solidContactID)/debitcard"
  }
  
  func process(response: VGSResponse, completion: (Result<Void, VaultError>) -> Void) {
    switch response {
    case let .success(_, data, _):
        guard let data = data, let _ = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
        completion(.success(()))
        return
      }
      completion(.success(()))
    case let .failure(_, data, _, error):
      if let error = error {
        completion(.failure(.unknownError(message: error.localizedDescription)))
      } else if let data = data {
        if let error = try? JSONDecoder().decode(ValidationError.self, from: data) {
          completion(.failure(.validationError(message: error.message)))
        } else if let error = try? JSONDecoder().decode(APIError.self, from: data) {
          completion(.failure(.unknownError(message: error.error)))
        } else {
          let message = String(decoding: data, as: UTF8.self)
          completion(.failure(.unknownError(message: message)))
        }
      } else {
        completion(.failure(.unknownError(message: "Something went wrong while contacting secure vault")))
      }
    }
  }
}
