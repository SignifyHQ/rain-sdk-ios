import UIKit

enum Country: String, Identifiable, CaseIterable {
  case US, AF, AX, AL, DZ, AS, AD, AO, AI, AQ, AG, AR, AM, AW, AU, AT, AZ, BS, BH, BD, BB, BY, BE, BZ, BJ, BM, BT, BO, BQ, BA, BW, BV, BR, IO, BN, BG, BF, BI, CV, KH, CM, CA, KY, CF, TD, CL, CN, CX, CC, CO, KM, CG, CD, CK, CR, CI, HR, CU, CW, CY, CZ, DK, DJ, DM, DO, EC, EG, SV, GQ, ER, EE, ET, FK, FO, FJ, FI, FR, GF, PF, TF, GA, GM, GE, DE, GH, GI, GR, GL, GD, GP, GU, GT, GG, GN, GW, GY, HT, HM, VA, HN, HK, HU, IS, IN, ID, IR, IQ, IE, IM, IL, IT, JM, JP, JE, JO, KZ, KE, KI, KP, KW, KG, LA, LV, LB, LS, LR, LY, LI, LT, LU, MO, MK, MG, MW, MY, MV, ML, MT, MH, MQ, MR, MU, YT, MX, FM, MD, MC, MN, ME, MS, MA, MZ, MM, NA, NR, NP, NL, NC, NZ, NI, NE, NG, NU, NF, MP, NO, OM, PK, PW, PS, PA, PG, PY, PE, PH, PN, PL, PT, PR, QA, RE, RO, RU, RW, BL, SH, KN, LC, MF, PM, VC, WS, SM, ST, SA, SN, RS, SC, SL, SG, SX, SK, SI, SB, SO, ZA, GS, KR, SS, ES, LK, SD, SR, SJ, SZ, SE, CH, SY, TW, TJ, TZ, TH, TL, TG, TK, TO, TT, TN, TR, TM, TC, TV, UG, UA, AE, GB, UM, UY, UZ, VU, VE, VN, VG, VI, WF, EH, YE, ZM, ZW
  
  var id: UUID {
    UUID()
  }
  
  var title: String {
    switch self {
    case .US:
      return "United States of America"
    case .AE:
      return "United Arab Emirates"
    case .AG:
      return "Antigua and Barbuda"
    case .AW:
      return "Aruba"
    case .AT:
      return "Austria"
    case .BS:
      return "Bahamas"
    case .BB:
      return "Barbados"
    case .BZ:
      return "Belize"
    case .BO:
      return "Bolivia"
    case .CA:
      return "Canada"
    case .CL:
      return "Chile"
    case .CO:
      return "Colombia"
    case .CR:
      return "Costa Rica"
    case .HR:
      return "Croatia"
    case .CY:
      return "Cyprus"
    case .DM:
      return "Dominica"
    case .DO:
      return "Dominican Republic"
    case .EC:
      return "Ecuador"
    case .SV:
      return "El Salvador"
    case .EE:
      return "Estonia"
    case .FI:
      return "Finland"
    case .FR:
      return "France"
    case .DE:
      return "Germany"
    case .AI:
      return "Anguilla"
    case .GI:
      return "Gibraltar"
    case .GP:
      return "Guadeloupe"
    case .GT:
      return "Guatemala"
    case .GG:
      return "Guernsey"
    case .HN:
      return "Honduras"
    case .JM:
      return "Jamaica"
    case .KR:
      return "South Korea"
    case .MT:
      return "Malta"
    case .MQ:
      return "Martinique"
    case .MX:
      return "Mexico"
    case .NI:
      return "Nicaragua"
    case .PA:
      return "Panama"
    case .PY:
      return "Paraguay"
    case .PE:
      return "Peru"
    case .PH:
      return "Philippines"
    case .PL:
      return "Poland"
    case .PR:
      return "Puerto Rico"
    case .RO:
      return "Romania"
    case .KN:
      return "Saint Kitts And Nevis"
    case .LC:
      return "Saint Lucia"
    case .SC:
      return "Seychelles"
    case .TW:
      return "Taiwan"
    case .TH:
      return "Thailand"
    case .TT:
      return "Trinidad and Tobago"
    case .TC:
      return "Turks and Caicos Islands"
    case .UY:
      return "Uruguay"
    case .MU:
      return "Republic of Mauritius"
    case .AL:
      return "Albania"
    case .AO:
      return "Angola"
    case .AR:
      return "Argentina"
    case .AU:
      return "Australia"
    case .BH:
      return "Bahrain"
    case .BE:
      return "Belgium"
    case .BA:
      return "Bosnia and Herzegovina"
    case .BR:
      return "Brazil"
    case .VG:
      return "British Virgin Islands"
    case .BG:
      return "Bulgaria"
    case .KY:
      return "Cayman Islands"
    case .CN:
      return "China"
    case .CZ:
      return "Czech Republic"
    case .CI:
      return "Côte D'Ivoir"
    case .DK:
      return "Denmark"
    case .ER:
      return "Eritrea"
    case .GE:
      return "Georgia"
    case .GR:
      return "Greece"
    case .GY:
      return "Guyana"
    case .HK:
      return "Hong Kong"
    case .HU:
      return "Hungary"
    case .IS:
      return "Iceland"
    case .IN:
      return "India"
    case .ID:
      return "Indonesia"
    case .IE:
      return "Ireland"
    case .IL:
      return "Israel"
    case .IT:
      return "Italy"
    case .JP:
      return "Japan"
    case .JO:
      return "Jordan"
    case .KE:
      return "Kenya"
    case .KW:
      return "Kuwait"
    case .LV:
      return "Latvia"
    case .LS:
      return "Lesotho"
    case .LI:
      return "Liechtenstein"
    case .LT:
      return "Lithuania"
    case .LU:
      return "Luxembourg"
    case .MO:
      return "Macao"
    case .MK:
      return "Macedonia"
    case .MY:
      return "Malaysia"
    case .MD:
      return "Republic of Moldova"
    case .NL:
      return "Netherlands"
    case .NZ:
      return "New Zealand"
    case .NO:
      return "Norway"
    case .OM:
      return "Oman"
    case .PK:
      return "Pakistan"
    case .PT:
      return "Portugal"
    case .QA:
      return "Qatar"
    case .RU:
      return "Russian Federation"
    case .SM:
      return "San Marino"
    case .SG:
      return "Singapore"
    case .SK:
      return "Slovakia"
    case .SI:
      return "Slovenia"
    case .ZA:
      return "South Africa"
    case .ES:
      return "Spain"
    case .LK:
      return "Sri Lanka"
    case .SE:
      return "Sweden"
    case .CH:
      return "Switzerland"
    case .TR:
      return "Turkey"
    case .GB:
      return "United Kingdom"
    case .VE:
      return "Venezuela"
    case .VN:
      return "Vietnam"
    case .ZM:
      return "Zambia"
    case .ZW:
      return "Zimbabwe"
    case .VC:
      return "Saint Vincent and the Grenadines"
    case .CW:
      return "Curacao"
    case .AF:
      return "Afghanistan"
    case .AX:
      return "Åland Islands"
    case .DZ:
      return "Algeria"
    case .AS:
      return "American Samoa"
    case .AD:
      return "Andorra"
    case .AQ:
      return "Antarctica"
    case .AM:
      return "Armenia"
    case .AZ:
      return "Azerbaijan"
    case .BD:
      return "Bangladesh"
    case .BY:
      return "Belarus"
    case .BJ:
      return "Benin"
    case .BM:
      return "Bermuda"
    case .BT:
      return "Bhutan"
    case .BQ:
      return "Bonaire, Sint Eustatius and Saba"
    case .BW:
      return "Botswana"
    case .BV:
      return "Bouvet Island"
    case .IO:
      return "British Indian Ocean Territory"
    case .BN:
      return "Brunei Darussalam"
    case .BF:
      return "Burkina Faso"
    case .BI:
      return "Burundi"
    case .CV:
      return "Cabo Verde"
    case .KH:
      return "Cambodia"
    case .CM:
      return "Cameroon"
    case .CF:
      return "Central African Republic"
    case .TD:
      return "Chad"
    case .CX:
      return "Christmas Island"
    case .CC:
      return "Cocos (Keeling) Islands"
    case .KM:
      return "Comoros"
    case .CG:
      return "Congo"
    case .CD:
      return "Congo (the Democratic Republic of the)"
    case .CK:
      return "Cook Islands"
    case .CU:
      return "Cuba"
    case .DJ:
      return "Djibouti"
    case .EG:
      return "Egypt"
    case .GQ:
      return "Equatorial Guinea"
    case .ET:
      return "Ethiopia"
    case .FK:
      return "Falkland Islands (Malvinas)"
    case .FO:
      return "Faroe Islands"
    case .FJ:
      return "Fiji"
    case .GF:
      return "French Guiana"
    case .PF:
      return "French Polynesia"
    case .TF:
      return "French Southern Territories"
    case .GA:
      return "Gabon"
    case .GM:
      return "Gambia"
    case .GH:
      return "Ghana"
    case .GL:
      return "Greenland"
    case .GD:
      return "Grenada"
    case .GU:
      return "Guam"
    case .GN:
      return "Guinea"
    case .GW:
      return "Guinea-Bissau"
    case .HT:
      return "Haiti"
    case .HM:
      return "Heard Island and McDonald Islands"
    case .VA:
      return "Holy See"
    case .IR:
      return "Iran (Islamic Republic of)"
    case .IQ:
      return "Iraq"
    case .IM:
      return "Isle of Man"
    case .JE:
      return "Jersey"
    case .KZ:
      return "Kazakhstan"
    case .KI:
      return "Kiribati"
    case .KP:
      return "Korea (the Democratic People's Republic of)"
    case .KG:
      return "Kyrgyzstan"
    case .LA:
      return "Lao People's Democratic Republic"
    case .LB:
      return "Lebanon"
    case .LR:
      return "Liberia"
    case .LY:
      return "Libya"
    case .MG:
      return "Madagascar"
    case .MW:
      return "Malawi"
    case .MV:
      return "Maldives"
    case .ML:
      return "Mali"
    case .MH:
      return "Marshall Islands"
    case .MR:
      return "Mauritania"
    case .YT:
      return "Mayotte"
    case .FM:
      return "Micronesia (Federated States of)"
    case .MC:
      return "Monaco"
    case .MN:
      return "Mongolia"
    case .ME:
      return "Montenegro"
    case .MS:
      return "Montserrat"
    case .MA:
      return "Morocco"
    case .MZ:
      return "Mozambique"
    case .MM:
      return "Myanmar"
    case .NA:
      return "Namibia"
    case .NR:
      return "Nauru"
    case .NP:
      return "Nepal"
    case .NC:
      return "New Caledonia"
    case .NE:
      return "Niger"
    case .NG:
      return "Nigeria"
    case .NU:
      return "Niue"
    case .NF:
      return "Norfolk Island"
    case .MP:
      return "Northern Mariana Islands"
    case .PW:
      return "Palau"
    case .PS:
      return "Palestine, State of"
    case .PG:
      return "Papua New Guinea"
    case .PN:
      return "Pitcairn"
    case .RE:
      return "Réunion"
    case .RW:
      return "Rwanda"
    case .BL:
      return "Saint Barthélemy"
    case .SH:
      return "Saint Helena, Ascension and Tristan da Cunha"
    case .MF:
      return "Saint Martin (French part)"
    case .PM:
      return "Saint Pierre and Miquelon"
    case .WS:
      return "Samoa"
    case .ST:
      return "Sao Tome and Principe"
    case .SA:
      return "Saudi Arabia"
    case .SN:
      return "Senegal"
    case .RS:
      return "Serbia"
    case .SL:
      return "Sierra Leone"
    case .SX:
      return "Sint Maarten (Dutch part)"
    case .SB:
      return "Solomon Islands"
    case .SO:
      return "Somalia"
    case .GS:
      return "South Georgia and the South Sandwich Islands"
    case .SS:
      return "South Sudan"
    case .SD:
      return "Sudan"
    case .SR:
      return "Suriname"
    case .SJ:
      return "Svalbard and Jan Mayen"
    case .SZ:
      return "Swaziland"
    case .SY:
      return "Syrian Arab Republic"
    case .TJ:
      return "Tajikistan"
    case .TZ:
      return "Tanzania, United Republic of"
    case .TL:
      return "Timor-Leste"
    case .TG:
      return "Togo"
    case .TK:
      return "Tokelau"
    case .TO:
      return "Tonga"
    case .TN:
      return "Tunisia"
    case .TM:
      return "Turkmenistan"
    case .TV:
      return "Tuvalu"
    case .UG:
      return "Uganda"
    case .UA:
      return "Ukraine"
    case .UM:
      return "United States Minor Outlying Islands"
    case .UZ:
      return "Uzbekistan"
    case .VU:
      return "Vanuatu"
    case .VI:
      return "Virgin Islands (U.S.)"
    case .WF:
      return "Wallis and Futuna"
    case .EH:
      return "Western Sahara"
    case .YE:
      return "Yemen"
    }
  }
  
  var phoneCode: String {
    switch self {
    case .AG:
      return "+1268"
    case .AI:
      return "+1264"
    case .AT:
      return "+43"
    case .AW:
      return "+297"
    case .BB:
      return "+1246"
    case .BO:
      return "+591"
    case .BS:
      return "+1242"
    case .BZ:
      return "+501"
    case .CA:
      return "+1"
    case .CL:
      return "+56"
    case .CO:
      return "+57"
    case .CR:
      return "+506"
    case .CY:
      return "+357"
    case .DE:
      return "+49"
    case .DM:
      return "+1767"
    case .DO:
      return "+1849"
    case .EC:
      return "+593"
    case .EE:
      return "+372"
    case .FI:
      return "+358"
    case .FR:
      return "+33"
    case .GI:
      return "+350"
    case .GG:
      return "+44"
    case .GP:
      return "+590"
    case .GT:
      return "+502"
    case .HN:
      return "+504"
    case .HR:
      return "+385"
    case .JM:
      return "+1876"
    case .KN:
      return "+1869"
    case .KR:
      return "+82"
    case .LC:
      return "+1758"
    case .MQ:
      return "+596"
    case .MT:
      return "+356"
    case .MX:
      return "+52"
    case .NI:
      return "+505"
    case .PA:
      return "+507"
    case .PE:
      return "+51"
    case .PH:
      return "+63"
    case .PL:
      return "+48"
    case .PR:
      return "+1"
    case .PY:
      return "+595"
    case .RO:
      return "+40"
    case .SC:
      return "+248"
    case .SV:
      return "+503"
    case .TC:
      return "+1649"
    case .TH:
      return "+66"
    case .TT:
      return "+1868"
    case .TW:
      return "+886"
    case .UY:
      return "+598"
    case .US:
      return "+1"
    case .VE:
      return "+58"
    case .AE:
      return "+971"
    case .MU:
      return "+230"
    case .AL:
      return "+355"
    case .AO:
      return "+244"
    case .AR:
      return "+54"
    case .AU:
      return "+61"
    case .BH:
      return "+973"
    case .BE:
      return "+32"
    case .BA:
      return "+387"
    case .BR:
      return "+55"
    case .VG:
      return "+1284"
    case .BG:
      return "+359"
    case .KY:
      return "+1345"
    case .CN:
      return "+86"
    case .CZ:
      return "+420"
    case .CI:
      return "+225"
    case .DK:
      return "+45"
    case .ER:
      return "+291"
    case .GE:
      return "+995"
    case .GR:
      return "+30"
    case .GY:
      return "+592"
    case .HK:
      return "+852"
    case .HU:
      return "+36"
    case .IS:
      return "+354"
    case .IN:
      return "+91"
    case .ID:
      return "+62"
    case .IE:
      return "+353"
    case .IL:
      return "+972"
    case .IT:
      return "+39"
    case .JP:
      return "+81"
    case .JO:
      return "+962"
    case .KE:
      return "+254"
    case .KW:
      return "+965"
    case .LV:
      return "+371"
    case .LS:
      return "+266"
    case .LI:
      return "+423"
    case .LT:
      return "+370"
    case .LU:
      return "+352"
    case .MO:
      return "+853"
    case .MK:
      return "+389"
    case .MY:
      return "+60"
    case .MD:
      return "+373"
    case .NL:
      return "+31"
    case .NZ:
      return "+64"
    case .NO:
      return "+47"
    case .OM:
      return "+968"
    case .PK:
      return "+92"
    case .PT:
      return "+351"
    case .QA:
      return "+974"
    case .RU:
      return "+7"
    case .SM:
      return "+378"
    case .SG:
      return "+65"
    case .SK:
      return "+421"
    case .SI:
      return "+386"
    case .ZA:
      return "+27"
    case .ES:
      return "+34"
    case .LK:
      return "+94"
    case .SE:
      return "+46"
    case .CH:
      return "+41"
    case .TR:
      return "+90"
    case .GB:
      return "+44"
    case .VN:
      return "+84"
    case .ZM:
      return "+260"
    case .ZW:
      return "+263"
    case .VC:
      return "+1784"
    case .CW:
      return "+599"
    case .AF:
        return "+93"
    case .AX:
        return "+358"
    case .DZ:
        return "+213"
    case .AS:
        return "+1684"
    case .AD:
        return "+376"
    case .AQ:
        return "+672"
    case .AM:
        return "+374"
    case .AZ:
        return "+994"
    case .BD:
        return "+880"
    case .BY:
        return "+375"
    case .BJ:
        return "+229"
    case .BM:
        return "+1441"
    case .BT:
        return "+975"
    case .BQ:
        return "+599"
    case .BW:
        return "+267"
    case .BV:
        return "+47"
    case .IO:
        return "+246"
    case .BN:
        return "+673"
    case .BF:
        return "+226"
    case .BI:
        return "+257"
    case .CV:
        return "+238"
    case .KH:
        return "+855"
    case .CM:
        return "+237"
    case .CF:
        return "+236"
    case .TD:
        return "+235"
    case .CX:
        return "+61"
    case .CC:
        return "+61"
    case .KM:
        return "+269"
    case .CG:
        return "+242"
    case .CD:
        return "+243"
    case .CK:
        return "+682"
    case .CU:
        return "+53"
    case .DJ:
        return "+253"
    case .EG:
        return "+20"
    case .GQ:
        return "+240"
    case .ET:
        return "+251"
    case .FK:
        return "+500"
    case .FO:
        return "+298"
    case .FJ:
        return "+679"
    case .GF:
        return "+594"
    case .PF:
        return "+689"
    case .TF:
        return "+262"
    case .GA:
        return "+241"
    case .GM:
        return "+220"
    case .GH:
        return "+233"
    case .GL:
        return "+299"
    case .GD:
        return "+1473"
    case .GU:
        return "+1671"
    case .GN:
        return "+224"
    case .GW:
        return "+245"
    case .HT:
        return "+509"
    case .HM:
        return "+61"
    case .VA:
        return "+379"
    case .IR:
        return "+98"
    case .IQ:
        return "+964"
    case .IM:
        return "+441624"
    case .JE:
        return "+441534"
    case .KZ:
        return "+7"
    case .KI:
        return "+686"
    case .KP:
        return "+850"
    case .KG:
        return "+996"
    case .LA:
        return "+856"
    case .LB:
        return "+961"
    case .LR:
        return "+231"
    case .LY:
        return "+218"
    case .MG:
        return "+261"
    case .MW:
        return "+265"
    case .MV:
        return "+960"
    case .ML:
        return "+223"
    case .MH:
        return "+692"
    case .MR:
        return "+222"
    case .YT:
        return "+262"
    case .FM:
        return "+691"
    case .MC:
        return "+377"
    case .MN:
        return "+976"
    case .ME:
        return "+382"
    case .MS:
        return "+1664"
    case .MA:
        return "+212"
    case .MZ:
        return "+258"
    case .MM:
        return "+95"
    case .NA:
        return "+264"
    case .NR:
        return "+674"
    case .NP:
        return "+977"
    case .NC:
        return "+687"
    case .NE:
        return "+227"
    case .NG:
        return "+234"
    case .NU:
        return "+683"
    case .NF:
        return "+672"
    case .MP:
        return "+1670"
    case .PW:
        return "+680"
    case .PS:
        return "+970"
    case .PG:
        return "+675"
    case .PN:
        return "+64"
    case .RE:
        return "+262"
    case .RW:
        return "+250"
    case .BL:
        return "+590"
    case .SH:
        return "+290"
    case .MF:
        return "+590"
    case .PM:
        return "+508"
    case .WS:
        return "+685"
    case .ST:
        return "+239"
    case .SA:
        return "+966"
    case .SN:
        return "+221"
    case .RS:
        return "+381"
    case .SL:
        return "+232"
    case .SX:
        return "+1721"
    case .SB:
        return "+677"
    case .SO:
        return "+252"
    case .GS:
        return "+500"
    case .SS:
        return "+211"
    case .SD:
        return "+249"
    case .SR:
        return "+597"
    case .SJ:
        return "+47"
    case .SZ:
        return "+268"
    case .SY:
        return "+963"
    case .TJ:
        return "+992"
    case .TZ:
        return "+255"
    case .TL:
        return "+670"
    case .TG:
        return "+228"
    case .TK:
        return "+690"
    case .TO:
        return "+676"
    case .TN:
        return "+216"
    case .TM:
        return "+993"
    case .TV:
        return "+688"
    case .UG:
        return "+256"
    case .UA:
        return "+380"
    case .UM:
        return "+246"
    case .UZ:
        return "+998"
    case .VU:
        return "+678"
    case .VI:
        return "+1340"
    case .WF:
        return "+681"
    case .EH:
        return "+212"
    case .YE:
        return "+967"

    }
  }
  
  func flagEmoji() -> String {
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
  
  init?(phoneCode: String) {
    guard let country = Country.allCases.first(where: { $0.phoneCode == phoneCode })
    else {
      return nil
    }
    
    self = country
  }
  
  init?(title: String) {
    guard let country = Country.allCases.first(where: { $0.title == title })
    else {
      return nil
    }
    
    self = country
  }
}
