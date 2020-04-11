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
  public let totalCases: Int
  public let totalDeaths: Int
  public let dailyCases: Int
  public let dailyDeaths: Int

  public func count(for type: ChartType) -> Int {
    switch type {
    case .dailyCases:
      return dailyCases
    case .dailyDeaths:
      return dailyDeaths
    case .totalCases:
      return totalCases
    case .totalDeaths:
      return totalDeaths
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
    case totalCases = "cases"
    case totalDeaths = "deaths"
    case dailyCases = "dailyCases"
    case dailyDeaths = "dailyDeaths"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let dateString = try container.decode(String.self, forKey: .date)
    date = StateSnapshot.formatter.date(from: dateString)!
    name = try container.decode(String.self, forKey: .name)
    FIPS = Int(try container.decode(String.self, forKey: .FIPS))!
    totalCases = Int(try container.decode(String.self, forKey: .totalCases))!
    totalDeaths = Int(try container.decode(String.self, forKey: .totalDeaths))!
    dailyCases = Int(try container.decodeIfPresent(String.self, forKey: .dailyCases) ?? "0")!
    dailyDeaths = Int(try container.decodeIfPresent(String.self, forKey: .dailyDeaths) ?? "0")!
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(StateSnapshot.formatter.string(from: date), forKey: .date)
    try container.encode(name, forKey: .name)
    try container.encode(String(FIPS), forKey: .FIPS)
    try container.encode(String(totalCases), forKey: .totalCases)
    try container.encode(String(totalDeaths), forKey: .totalDeaths)
    try container.encodeIfPresent(String(dailyCases), forKey: .dailyCases)
    try container.encodeIfPresent(String(dailyDeaths), forKey: .dailyDeaths)
  }

  private static let formatter: DateFormatter = {
    let formatter = DateFormatter.autoUpdatingFormatter
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
  }()
}

