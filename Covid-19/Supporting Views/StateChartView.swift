//  
//  Covid-19
//
//  Copyright © 2020 Jay Hickey. All rights reserved.
//

import SwiftUI
import CovidLib

struct StateChartView: View {
  @ObservedObject var store: Store
  let type: ChartType

  var selectedStates: [[StateSnapshot]] {
    // Total selected
    store.value.chart.selectedChartStates
      .compactMap {
        selectedName in store.value.totalUS.first?.name == selectedName
          ? store.value.totalUS
          : nil
    }
    +
    // Individual states selected
    store.value.chart.selectedChartStates
      .compactMap { selectedName in
        store.value.states.first { $0.name == selectedName }
    }
    .map { $0.snapshots }
  }

  var body: some View {
    ChartView(
      states: selectedStates,
      type: type,
      onValueDeselected: {
        withAnimation {
          self.store.dispatch(.selectedChartValue(nil))
        }
    }) { entry in
      withAnimation {
        self.store.dispatch(.selectedChartValue(
          (Date(timeIntervalSince1970: entry.x), Int(entry.y)))
        )
      }
    }
    .equatable()
  }
}

struct StateChartView_Previews: PreviewProvider {
  static var previews: some View {
    StateChartView(store: AppEnvironment.store, type: .deaths)
  }
}
