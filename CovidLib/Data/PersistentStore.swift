//  
//  Covid-19
//
//  Copyright © 2020 Jay Hickey. All rights reserved.
//

import Foundation

private let saveQueue = DispatchQueue(label: "com.CovidLib.persistentStoreQueue")

enum PersistentStore {
  static let fileURL = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/data")

  static let key = "Covid-19 AppState"
  static func save(state: AppState) {
    saveQueue.async {
      let encoder = JSONEncoder()
      do {
        let data = try encoder.encode(state)
        try data.write(to: fileURL, options: [.atomic])
      } catch let error {
        fatalError("Unable to save app state: \(error)")
      }
    }
  }

  static func load() -> AppState? {
    guard let data = try? Data(contentsOf: fileURL) else {
      return nil
    }
    let decoder = JSONDecoder()
    return try? decoder.decode(AppState.self, from: data)
  }
}
