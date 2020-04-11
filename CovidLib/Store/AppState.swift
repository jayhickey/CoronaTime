//  
//  Covid-19
//
//  Copyright © 2020 Jay Hickey. All rights reserved.
//

import Foundation

public struct AppState: Codable {
  public internal(set) var selectedTab: Int = 0
  public internal(set) var states: [State] = []
  public internal(set) var chart: ChartUI = ChartUI()
  public internal(set) var totalUS: [StateSnapshot] = []
}
