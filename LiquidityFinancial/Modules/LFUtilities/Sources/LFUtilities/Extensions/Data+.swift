//
//  File.swift
//  
//
//  Created by Tran Minh Luan on 16/07/2023.
//

import Foundation

extension Data {
  func convertToJsonDictionary() -> [String: Any]? {
    do {
      let decoded = try JSONSerialization.jsonObject(with: self, options: .allowFragments) as? [String: Any]
      if let dictFromJSON = decoded {
        return dictFromJSON
      }
    } catch {
      print(error.localizedDescription)
    }
    return nil
  }
}
