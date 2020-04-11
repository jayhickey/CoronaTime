//  
//  Covid-19
//
//  Copyright © 2020 Jay Hickey. All rights reserved.
//

import Foundation

public enum AppAction {
  // MARK: - Data Fetching
  case fetchStates
  case fetchCounties
  case setStates([State])
  case setCounties([County])
  case setTotal([DataSnapshot])

  // MARK: - UI
  case selectedTab(Int)

  // MARK: Charts
  case selectedChartItem(String)
  case selectedChartType(ChartType)
  case selectedChartValue((Date, Int)?)
}
