//  
//  Covid-19
//
//  Copyright © 2020 Jay Hickey. All rights reserved.
//

import Foundation

public enum ChartType: String, Codable, CaseIterable {
  case cases
  case deaths
}

public struct ChartValue: Codable {
  public let date: Date
  public let value: Int
}

public struct ChartUI: Codable {
  public internal(set) var selectedChartStates: [String] = []
  public internal(set) var chartType = ChartType.cases
  public internal(set) var selectedChartValue: ChartValue? = nil
}
