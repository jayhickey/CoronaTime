//  
//  CoronaTime
//
//  Copyright © 2020 Jay Hickey. All rights reserved.
//

import Foundation
import CoreLocation

public struct County: Codable, Identifiable {
  public let id = UUID()
  public let name: String
  public let state: String
  public let FIPS: Int
  public let snapshots: [DataSnapshot]
  
  public var location: Location {
    snapshots.first!.location!
  }

  internal init(name: String, state: String, FIPS: Int, snapshots: [DataSnapshot]) {
    self.name = name
    self.state = state
    self.FIPS = FIPS
    self.snapshots = snapshots.sorted()
  }
}

extension County: Hashable {
  public static func == (lhs: County, rhs: County) -> Bool {
    return lhs.name == rhs.name
      && lhs.state == rhs.state
      && lhs.FIPS == rhs.FIPS
      && lhs.snapshots == rhs.snapshots
  }
}

extension County: Comparable {
  public static func < (lhs: County, rhs: County) -> Bool {
    return lhs.state < rhs.state && lhs.name < rhs.name
  }
}
