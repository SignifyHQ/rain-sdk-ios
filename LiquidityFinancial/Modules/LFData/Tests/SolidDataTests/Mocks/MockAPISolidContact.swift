import SolidData

enum MockAPISolidContact {
  static var mockSuccessData: APISolidContact {
    APISolidContact(
      name: "mock_name",
      last4: "mock_last4",
      type: "mock_type",
      solidContactId: "mock_solid_contact_id"
    )
  }

  static var mockEmptyData: APISolidContact {
    APISolidContact(
      name: "",
      last4: "",
      type: "",
      solidContactId: ""
    )
  }
}
