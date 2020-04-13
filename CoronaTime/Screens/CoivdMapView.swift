//  
//  CoronaTime
//
//  Copyright © 2020 Jay Hickey. All rights reserved.
//

import SwiftUI
import CoronaTimeLib

struct CoivdMapView: View {
  @ObservedObject var store: Store

  var body: some View {
    MapView(snapshots: store.value.counties.compactMap { $0.snapshots.first })
    .edgesIgnoringSafeArea(.all)
  }
}


struct CoivdMapView_Previews: PreviewProvider {
  static var previews: some View {
    CoivdMapView(store: AppEnvironment.store)
  }
}
