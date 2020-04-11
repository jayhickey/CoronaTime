//  
//  Covid-19
//
//  Copyright © 2020 Jay Hickey. All rights reserved.
//

import Foundation

public func appReducer(appState: inout AppState, actions: AppAction) {
  switch actions {

  // MARK: - Data Fetching

  case .fetchStates:
    AppEnvironment.dataLoader.fetchStates()
  case .fetchCounties:
    AppEnvironment.dataLoader.fetchCounties()
  case .setStates(let states):
    appState.states = states.sorted()
  case .setCounties(let counties):
    appState.counties = counties
  case .setTotal(let total):
    appState.totalUS = total

  // MARK: - UI

  case .selectedTab(let index):
    appState.selectedTab = index

  // MARK: - Charts

  case .selectedChartItem(let chartName):
    if appState.chart.selectedChartStates.contains(chartName) {
      appState.chart.selectedChartStates.removeAll { $0 == chartName }
    }
    else {
      appState.chart.selectedChartStates.append(chartName)
    }
  case .selectedChartType(let type):
    appState.chart.chartType = type

  case .selectedChartValue(let (date, value)?):
    appState.chart.selectedChartValue = ChartValue(date: date, value: value)
  case .selectedChartValue(.none):
    appState.chart.selectedChartValue = nil
  }
}
