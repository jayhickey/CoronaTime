//  
//  Covid-19
//
//  Copyright © 2020 Jay Hickey. All rights reserved.
//

import Foundation

enum PersistentStore {
  static let key = "Covid-19 AppState"
  static func save(state: AppState) {
    let encoder = JSONEncoder()
    do {
      let data = try encoder.encode(state)
      UserDefaults.standard.set(data, forKey: Self.key)
    } catch let error {
      fatalError("Unable to save app state: \(error)")
    }
  }

  static func load() -> AppState? {
    let decoder = JSONDecoder()
    guard let data = UserDefaults.standard.data(forKey: Self.key) else {
      return nil
    }
    return try? decoder.decode(AppState.self, from: data)
  }
}
