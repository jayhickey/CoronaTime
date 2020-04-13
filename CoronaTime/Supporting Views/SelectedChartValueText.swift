//  
//  CoronaTime
//
//  Copyright © 2020 Jay Hickey. All rights reserved.
//

import SwiftUI
import CoronaTimeLib

struct SelectedChartValueText: View {
  @ObservedObject var store: Store

  private var numberFormatter: NumberFormatter {
    let f = NumberFormatter()
    f.locale = .autoupdatingCurrent
    f.numberStyle = .decimal
    f.usesGroupingSeparator = true
    return f
  }

  var body: Text? {
    return selectedValue()
  }

  private func selectedValue() -> Text? {
    guard let date = self.store.value.chart.selectedChartValue?.date,
      let count = self.store.value.chart.selectedChartValue?.value,
      let formattedCount = numberFormatter.string(from: NSNumber(value: count)) else {
        return nil
    }
    let chartType = self.store.value.chart.chartType.rawValue.uppercased()
    var dateFormatter: DateFormatter {
      let f = DateFormatter.autoUpdatingFormatter
      f.dateFormat = "MMM dd"
      return f
    }
    return Text("\(dateFormatter.string(from: date)): \(formattedCount) \(chartType)")
  }
}

struct SelectedChartValueText_Previews: PreviewProvider {
  static var previews: some View {
    SelectedChartValueText(store: AppEnvironment.store)
  }
}
