// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import NetspendDomain

public class MockAddressCardParametersEntity: AddressCardParametersEntity {

    public init() {}

    public var line1: String?
    public var line2: String?
    public var city: String?
    public var state: String?
    public var postalCode: String?
    public var country: String?

    //MARK: - init

    public var initLine1Line2CityStateCountryPostalCodeReceivedArguments: (line1: String?, line2: String?, city: String?, state: String?, country: String?, postalCode: String?)?
    public var initLine1Line2CityStateCountryPostalCodeReceivedInvocations: [(line1: String?, line2: String?, city: String?, state: String?, country: String?, postalCode: String?)] = []
    public var initLine1Line2CityStateCountryPostalCodeClosure: ((String?, String?, String?, String?, String?, String?) -> Void)?

    public required init(line1: String?, line2: String?, city: String?, state: String?, country: String?, postalCode: String?) {
        initLine1Line2CityStateCountryPostalCodeReceivedArguments = (line1: line1, line2: line2, city: city, state: state, country: country, postalCode: postalCode)
        initLine1Line2CityStateCountryPostalCodeReceivedInvocations.append((line1: line1, line2: line2, city: city, state: state, country: country, postalCode: postalCode))
        initLine1Line2CityStateCountryPostalCodeClosure?(line1, line2, city, state, country, postalCode)
    }
}
