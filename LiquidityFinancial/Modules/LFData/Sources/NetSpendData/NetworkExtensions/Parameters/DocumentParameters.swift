import Foundation
import DataUtilities

public struct PathDocumentParameters: Parameterable {
  public let sessionId, documentID: String
  public let isUpdate: Bool
  public init(sessionId: String, documentID: String, isUpdate: Bool) {
    self.sessionId = sessionId
    self.documentID = documentID
    self.isUpdate = isUpdate
  }
}

public struct DocumentParameters: Parameterable {
  public let purpose: String
  public let documents: [Document]
  
  public init(purpose: String, documents: [Document]) {
    self.purpose = purpose
    self.documents = documents
  }
  
  public struct Document: Codable {
    public let documentType: String
    public let country, encryptedData: String
    
    public init(documentType: String, country: String, encryptedData: String) {
      self.documentType = documentType
      self.country = country
      self.encryptedData = encryptedData
    }
  }
}

public struct DocumentEncryptedData: Parameterable {
  public var frontImageContentType: String
  public var frontImage: String
  public var backImageContentType: String
  public var backImage: String
  
  public init(frontImageContentType: String = "", frontImage: String = "", backImageContentType: String = "", backImage: String = "") {
    self.frontImageContentType = frontImageContentType
    self.frontImage = frontImage
    self.backImageContentType = backImageContentType
    self.backImage = backImage
  }
  
  enum CodingKeys: String, CodingKey {
    case frontImageContentType = "front_image_content_type"
    case frontImage = "front_image"
    case backImageContentType = "back_image_content_type"
    case backImage = "back_image"
  }
}
