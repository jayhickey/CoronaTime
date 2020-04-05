//  
//  Covid-19
//
//  Copyright © 2020 Jay Hickey. All rights reserved.
//

import Foundation

public struct StateSnapshot: Hashable {
  public let date: Date
  public let name: String
  public let FIPS: Int
  public let cases: Int
  public let deaths: Int

  public func count(for type: ChartType) -> Int {
    switch type {
    case .cases:
      return cases
    case .deaths:
      return deaths
    }
  }
}

extension StateSnapshot: Comparable {
  public static func < (lhs: StateSnapshot, rhs: StateSnapshot) -> Bool {
    return lhs.date < rhs.date
  }
}

extension StateSnapshot: Codable {

  enum CodingKeys: String, CodingKey {
    case date = "date"
    case name = "state"
    case FIPS = "fips"
    case cases = "cases"
    case deaths = "deaths"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let dateString = try container.decode(String.self, forKey: .date)
    date = StateSnapshot.formatter.date(from: dateString)!
    name = try container.decode(String.self, forKey: .name)
    FIPS = Int(try container.decode(String.self, forKey: .FIPS))!
    cases = Int(try container.decode(String.self, forKey: .cases))!
    deaths = Int(try container.decode(String.self, forKey: .deaths))!
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(StateSnapshot.formatter.string(from: date), forKey: .date)
    try container.encode(name, forKey: .name)
    try container.encode(String(FIPS), forKey: .FIPS)
    try container.encode(String(cases), forKey: .cases)
    try container.encode(String(deaths), forKey: .deaths)
  }

  private static let formatter: DateFormatter = {
    let formatter = DateFormatter.autoUpdatingFormatter
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
  }()
}

