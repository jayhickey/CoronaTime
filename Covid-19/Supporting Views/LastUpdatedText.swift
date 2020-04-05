//  
//  Covid-19
//
//  Copyright © 2020 Jay Hickey. All rights reserved.
//

import SwiftUI
import CovidLib

struct LastUpdatedText: View {
  @ObservedObject var store: Store

  var mostRecentSnapshot: StateSnapshot? {
    store.value.states
    .compactMap({ $0.snapshots.last })
    .sorted()
    .last
  }
  
  var dateFormatter: DateFormatter {
    let f = DateFormatter.autoUpdatingFormatter
    f.dateFormat = "MMMM d"
    return f
  }

  var body: Text? {
    mostRecentSnapshot.map { Text("As of \(dateFormatter.string(from: $0.date))") }
  }
}

struct LastUpdatedView_Previews: PreviewProvider {
  static var previews: some View {
    LastUpdatedText(store: AppEnvironment.store)
  }
}
