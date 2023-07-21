import Foundation

public enum NetSpendDocumentType: String, Codable {
  case foreignId = "foreign_id"
  case other = "other"
  case passport = "passport"
  case payStubDatedWithin30Days = "pay_stub_dated_within_30_days"
  case socialSecurityCard = "social_security_card"
  case stateIssuedPhotoId = "state_issued_photo_id"
  case utilityBill = "utility_bill"
}

public enum NetSpendDocumentDescription: String, Codable {
  case addressVerification = "address_verification"
  case identityVerification = "identity_verification"
  case proofOfNameChange = "proof_of_name_change"
  case secondaryDocument = "secondary_document"
  case ssnDocument = "ssn_document"
}

public enum NetSpendDocumentRequestContentTypes: String, Codable {
  case msword = "application/msword"
  case pdf = "application/pdf"
  case openxmlformats = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
  case bmp = "image/bmp"
  case gif = "image/gif"
  case jpeg = "image/jpeg"
  case png = "image/png"
}

public enum NetSpendDocumentReviewStatus: String, Codable {
  case complete = "complete"
  case open = "open"
  case reviewInProgress = "review_in_progress"
}

public enum NetSpendDocumentReviewStatusReason: String, Codable {
  case accepted
  case rejected
  case required
  case underReview = "under_review"
}
