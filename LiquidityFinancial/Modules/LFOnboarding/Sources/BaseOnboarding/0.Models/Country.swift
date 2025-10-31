import UIKit

public enum Country: String, Identifiable, CaseIterable {
  case US, AG, AR, AU, BS, BB, BD, BZ, BO, BR, KY, CO, CR, CI , DO, DM, EC, EG, SV, GH, GD, GT, GY, HN, HK, JP, KE, MY, MX, MA, NZ, NG, PK, PA, PY, PE, PH, KN, LC, VC, SN, SG, ZA, LK, SR, TH, TT, TC, AE, UG, UY, ZM  // Zambia
  
  public var id: UUID {
    UUID()
  }
  
  public var title: String {
    switch self {
    case .US:
      return "United States"
    case .AE:
      return "United Arab Emirates"
    case .AG:
      return "Antigua and Barbuda"
    case .BS:
      return "Bahamas"
    case .BB:
      return "Barbados"
    case .BZ:
      return "Belize"
    case .BO:
      return "Bolivia"
    case .CO:
      return "Colombia"
    case .CR:
      return "Costa Rica"
    case .DM:
      return "Dominica"
    case .DO:
      return "Dominican Republic"
    case .EC:
      return "Ecuador"
    case .GD:
      return "Grenada"
    case .SV:
      return "El Salvador"
    case .GT:
      return "Guatemala"
    case .HN:
      return "Honduras"
    case .MX:
      return "Mexico"
    case .PA:
      return "Panama"
    case .PY:
      return "Paraguay"
    case .PE:
      return "Peru"
    case .PH:
      return "Philippines"
    case .KN:
      return "Saint Kitts And Nevis"
    case .LC:
      return "Saint Lucia"
    case .TH:
      return "Thailand"
    case .TT:
      return "Trinidad and Tobago"
    case .TC:
      return "Turks and Caicos Islands"
    case .UY:
      return "Uruguay"
    case .AR:
      return "Argentina"
    case .AU:
      return "Australia"
    case .BR:
      return "Brazil"
    case .KY:
      return "Cayman Islands"
    case .CI:
      return "Côte D'Ivoir"
    case .GY:
      return "Guyana"
    case .HK:
      return "Hong Kong"
    case .JP:
      return "Japan"
    case .KE:
      return "Kenya"
    case .MA:
      return "Morocco"
    case .MY:
      return "Malaysia"
    case .NG:
      return "Nigeria"
    case .NZ:
      return "New Zealand"
    case .PK:
      return "Pakistan"
    case .SG:
      return "Singapore"
    case .ZA:
      return "South Africa"
    case .LK:
      return "Sri Lanka"
    case .ZM:
      return "Zambia"
    case .VC:
      return "Saint Vincent and the Grenadines"
    case .BD:
      return "Bangladesh"
    case .EG:
      return "Egypt"
    case .GH:
      return "Ghana"
    case .SN:
      return "Senegal"
    case .SR:
      return "Suriname"
    case .UG:
      return "Uganda"
    }
  }
  
  public var phoneCode: String {
    switch self {
    case .AG:
      return "+1268"
    case .BB:
      return "+1246"
    case .BO:
      return "+591"
    case .BS:
      return "+1242"
    case .BZ:
      return "+501"
    case .CO:
      return "+57"
    case .CR:
      return "+506"
    case .DM:
      return "+1767"
    case .DO:
      return "+1849"
    case .EC:
      return "+593"
    case .GT:
      return "+502"
    case .HN:
      return "+504"
    case .KN:
      return "+1869"
    case .LC:
      return "+1758"
    case .MX:
      return "+52"
    case .PA:
      return "+507"
    case .PE:
      return "+51"
    case .PH:
      return "+63"
    case .PY:
      return "+595"
    case .SV:
      return "+503"
    case .TC:
      return "+1649"
    case .TH:
      return "+66"
    case .TT:
      return "+1868"
    case .UY:
      return "+598"
    case .US:
      return "+1"
    case .AE:
      return "+971"
    case .AR:
      return "+54"
    case .AU:
      return "+61"
    case .BR:
      return "+55"
    case .KY:
      return "+1345"
    case .CI:
      return "+225"
    case .GY:
      return "+592"
    case .HK:
      return "+852"
    case .JP:
      return "+81"
    case .KE:
      return "+254"
    case .MY:
      return "+60"
    case .MA:
        return "+212"
    case .NZ:
      return "+64"
    case .PK:
      return "+92"
    case .SG:
      return "+65"
    case .ZA:
      return "+27"
    case .LK:
      return "+94"
    case .ZM:
      return "+260"
    case .VC:
      return "+1784"
    case .BD:
        return "+880"
    case .EG:
        return "+20"
    case .GH:
        return "+233"
    case .GD:
        return "+1473"
    case .NG:
        return "+234"
    case .SN:
        return "+221"
    case .SR:
        return "+597"
    case .UG:
        return "+256"
    }
  }
  
  public func flagEmoji() -> String {
    let firstChar = self.rawValue[self.rawValue.startIndex]
    let secondChar = self.rawValue[self.rawValue.index(self.rawValue.startIndex, offsetBy: 1)]
    
    let flagBase: UInt32 = 0x1F1E6
    
    guard let aCharAscii = Character("A").asciiValue,
          let firstCharAscii = firstChar.asciiValue,
          let secondCharAscii = secondChar.asciiValue,
          let a = try? UInt32(firstCharAscii - aCharAscii),
          let b = try? UInt32(secondCharAscii - aCharAscii),
          let firstFlag = UnicodeScalar(flagBase + a),
          let secondFlag = UnicodeScalar(flagBase + b)
    else {
      return "🌎"
    }
    
    return String(firstFlag) + String(secondFlag)
  }
  
  public init?(phoneCode: String) {
    guard let country = Country.allCases.first(where: { $0.phoneCode == phoneCode })
    else {
      return nil
    }
    
    self = country
  }
  
  public init?(title: String) {
    guard let country = Country.allCases.first(where: { $0.title == title })
    else {
      return nil
    }
    
    self = country
  }
}
