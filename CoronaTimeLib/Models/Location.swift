//  
//  CoronaTime
//
//  Copyright © 2020 Jay Hickey. All rights reserved.
//

import Foundation
import CoreLocation

public struct Location: Codable, Hashable {
  let latitude: Double
  let longitude: Double
}

public extension Location {
  var coordinate: CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
}
