//  
//  Covid-19
//
//  Copyright © 2020 Jay Hickey. All rights reserved.
//

import Foundation

public enum ChartType: String, Codable, CaseIterable {
  case totalCases = "Total Cases"
  case totalDeaths = "Total Deaths"
  case dailyCases = "Daily Cases"
  case dailyDeaths = "Daily Deaths"
}

public struct ChartValue: Codable {
  public let date: Date
  public let value: Int
}

public struct ChartUI: Codable {
  public internal(set) var selectedChartStates: [String] = []
  public internal(set) var chartType = ChartType.totalCases
  public internal(set) var selectedChartValue: ChartValue? = nil
}
