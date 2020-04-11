//  
//  Covid-19
//
//  Copyright © 2020 Jay Hickey. All rights reserved.
//

import SwiftUI
import CovidLib
import Charts

struct ChartsView: View {
  @ObservedObject var store: Store

  private var hasSelectedStates: Bool {
    store.value.chart.selectedChartStates.count > 0
  }

  private var chartType: ChartType {
    store.value.chart.chartType
  }

  var body: some View {
    VStack {
      VStack {
        Text("US Totals: \(store.value.totalUS.last?.totalCases ?? 0) cases • \(store.value.totalUS.last?.totalDeaths ?? 0) deaths")
          .font(.headline)
        LastUpdatedText(store: store)
          .font(.footnote)
          .frame(maxWidth: .infinity)
      }
      if hasSelectedStates {
        VStack {
          ChartTypePicker(initialType: chartType) {
            self.store.dispatch(.selectedChartType(ChartType.allCases[$0]))
          }
          StateChartView(store: store, type: chartType)
          SelectedChartValueText(store: store)
            .font(.footnote)
            .animation(nil)
        }
        .padding(EdgeInsets(top: 0, leading: 16, bottom: 4, trailing: 16))
      }
      List {
        Section {
          totalRow()
        }
        Section {
          ForEach(store.value.states) { state in
            MultipleSelectionRow(
              title: state.name,
              subtitle: self.subtitle(for: state.snapshots.last),
              isSelected: self.store.value.chart.selectedChartStates.contains(state.name)) {
                withAnimation {
                  self.store.dispatch(.selectedChartItem(state.name))
                }
            }
          }
        }
      }
      .listStyle(GroupedListStyle())
      .environment(\.horizontalSizeClass, .regular)
    }
  }

  // MARK: - Private

  private func subtitle(for snapshot: DataSnapshot?) -> String {
    var numberFormatter: NumberFormatter {
      let f = NumberFormatter()
      f.locale = .autoupdatingCurrent
      f.numberStyle = .decimal
      f.usesGroupingSeparator = true
      return f
    }
    
    guard let snapshot = snapshot,
      let cases = numberFormatter.string(from: NSNumber(value: snapshot.totalCases)),
      let deaths = numberFormatter.string(from: NSNumber(value: snapshot.totalDeaths))
    else { return "" }
    return "\(cases) cases • \(deaths) deaths"
  }

  private func totalRow() -> MultipleSelectionRow? {
    guard let snapshot = store.value.totalUS.last else { return nil }
    return MultipleSelectionRow(
      title: snapshot.state,
      subtitle: self.subtitle(for: snapshot),
      isSelected: self.store.value.chart.selectedChartStates.contains(snapshot.state)) {
        withAnimation {
          self.store.dispatch(.selectedChartItem(snapshot.state))
        }
    }
  }
}

struct ChartsView_Previews: PreviewProvider {
  static var previews: some View {
    ChartsView(store: AppEnvironment.store)
  }
}

