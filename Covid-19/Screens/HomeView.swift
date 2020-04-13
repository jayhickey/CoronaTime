//  
//  Covid-19
//
//  Copyright © 2020 Jay Hickey. All rights reserved.
//

import SwiftUI
import CovidLib

struct HomeView: View {
  @ObservedObject var store: Store

  var body: some View {
    TabView(selection: Binding(
      get: { self.store.value.selectedTab },
      set: { self.store.dispatch(.selectedTab($0)) })
    ) {
      ChartsView(store: store)
        .tabItem {
          VStack {
            Image(systemName: "list.bullet.below.rectangle")
            Text("Charts")
          }
      }.tag(0)
      
      CoivdMapView(store: store)
        .edgesIgnoringSafeArea(.all)
        .tabItem {
          VStack {
            Image(systemName: "map")
            Text("Map")
          }
      }.tag(1)
    }
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView(store: AppEnvironment.store)
  }
}
