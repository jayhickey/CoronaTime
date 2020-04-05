//  
//  Covid-19
//
//  Copyright © 2020 Jay Hickey. All rights reserved.
//

import Foundation

public func appReducer(state: inout AppState, actions: AppAction) {
  switch actions {

  // MARK: - Data Fetching

  case .fetchStates:
    AppEnvironment.dataLoader.fetchStates()
  case .setStates(let states):
    state.states = states.sorted()
  case .setTotal(let total):
    state.total = total

  // MARK: - UI

  case .selectedTab(let index):
    state.selectedTab = index

  // MARK: - Charts

  case .selectedChartItem(let chartName):
    if state.chart.selectedChartStates.contains(chartName) {
      state.chart.selectedChartStates.removeAll { $0 == chartName }
    }
    else {
      state.chart.selectedChartStates.append(chartName)
    }
  case .selectedChartType(let type):
    state.chart.chartType = type

  case .selectedChartValue(let (date, value)?):
    state.chart.selectedChartValue = ChartValue(date: date, value: value)
  case .selectedChartValue(.none):
    state.chart.selectedChartValue = nil
  }
}
