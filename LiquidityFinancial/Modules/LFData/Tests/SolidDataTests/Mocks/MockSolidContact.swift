import SolidData

enum MockSolidContact {
  static var mockSuccessData: SolidContact {
    SolidContact(
      name: "mock_name",
      last4: "mock_last4",
      type: "mock_type",
      solidContactId: "mock_solid_contact_id"
    )
  }

  static var mockEmptyData: SolidContact {
    SolidContact(
      name: "",
      last4: "",
      type: "",
      solidContactId: ""
    )
  }
}
