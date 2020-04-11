//  
//  Covid-19
//
//  Copyright © 2020 Jay Hickey. All rights reserved.
//

import Foundation
import CoreLocation

public struct DataSnapshot: Hashable {
  public let date: Date
  public let state: String
  public let county: String
  public let FIPS: Int
  public let totalCases: Int
  public let totalDeaths: Int
  public let dailyCases: Int
  public let dailyDeaths: Int

  public internal(set) var location: Location? = nil

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

extension DataSnapshot: Comparable {
  public static func < (lhs: DataSnapshot, rhs: DataSnapshot) -> Bool {
    return lhs.date < rhs.date
  }
}

extension DataSnapshot: Codable {

  enum CodingKeys: String, CodingKey {
    case date = "date"
    case state = "state"
    case FIPS = "fips"
    case totalCases = "cases"
    case totalDeaths = "deaths"
    case dailyCases = "dailyCases"
    case dailyDeaths = "dailyDeaths"
    case county = "county"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let dateString = try container.decode(String.self, forKey: .date)
    date = DataSnapshot.formatter.date(from: dateString)!
    state = try container.decode(String.self, forKey: .state)
    county = try (container.decodeIfPresent(String.self, forKey: .county) ?? "N/A")
    FIPS = Int(try container.decode(String.self, forKey: .FIPS))!
    totalCases = Int(try container.decodeIfPresent(String.self, forKey: .totalCases) ?? "0")!
    totalDeaths = Int(try container.decodeIfPresent(String.self, forKey: .totalDeaths) ?? "0")!
    dailyCases = Int(try container.decodeIfPresent(String.self, forKey: .dailyCases) ?? "0")!
    dailyDeaths = Int(try container.decodeIfPresent(String.self, forKey: .dailyDeaths) ?? "0")!
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(DataSnapshot.formatter.string(from: date), forKey: .date)
    try container.encode(state, forKey: .state)
    try container.encode(county, forKey: .county)
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

