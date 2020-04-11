//  
//  Covid-19
//
//  Copyright © 2020 Jay Hickey. All rights reserved.
//

import Foundation

public struct State: Codable, Identifiable {
  public let id = UUID()
  public let name: String
  public let FIPS: Int
  public let snapshots: [DataSnapshot]

  internal init(name: String, FIPS: Int, snapshots: [DataSnapshot]) {
    self.name = name
    self.FIPS = FIPS
    self.snapshots = snapshots.sorted()
  }
}

extension State: Hashable {
  public static func == (lhs: State, rhs: State) -> Bool {
    return lhs.name == rhs.name
      && lhs.FIPS == rhs.FIPS
      && lhs.snapshots == rhs.snapshots
  }
}

extension State: Comparable {
  public static func < (lhs: State, rhs: State) -> Bool {
    return lhs.name < rhs.name
  }
}
