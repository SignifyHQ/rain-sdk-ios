import Foundation

public enum WorkflowsMissingStep: String, Codable, CaseIterable {
  case identityQuestions = "identity_questions"
  case provideDocuments = "provide_documents"
  case primaryPersonKYCApprove = "primary_person_kyc_approve"
  case KYCData = "kyc_data"
  case acceptAgreement = "accept_agreement"
  case expectedUse = "expected_use"
  case identityScan = "identity_scan"
}

public struct APIWorkflowsData: Decodable {
  public let steps: [APIWorkflowsData.WorkflowsStep]
  
  public struct WorkflowsStep: Codable {
    public let name: String
    public let steps: [APIWorkflowsData.Step]
  }
  
  public struct Step: Codable {
    public let missingStep: WorkflowsMissingStep
    public let relatedId: String?
    
    enum CodingKeys: String, CodingKey {
      case missingStep = "step"
      case relatedId = "related_id"
    }
  }
}
