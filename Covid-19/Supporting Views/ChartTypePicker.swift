//  
//  Covid-19
//
//  Copyright © 2020 Jay Hickey. All rights reserved.
//

import SwiftUI
import CovidLib

struct ChartTypePicker: View {
  var initialType: ChartType
  var onSelect: (Int) -> Void
  var body: some View {
    Picker("Chart Type",
      selection: Binding(
        get: { ChartType.allCases.firstIndex(of: self.initialType)! },
        set: { self.onSelect($0) })) {
        ForEach(0..<ChartType.allCases.count, id: \.self) { index in
          Text(ChartType.allCases[index].rawValue.capitalized).tag(index)
        }
    }
    .pickerStyle(SegmentedPickerStyle())
  }
}
