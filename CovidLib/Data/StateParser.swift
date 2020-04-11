//  
//  Covid-19
//
//  Copyright © 2020 Jay Hickey. All rights reserved.
//

import Foundation

struct StateSnapshotContainer: Codable {
  let states: [StateSnapshot]
}

enum StateParser {
  static func states(from container: StateSnapshotContainer) -> [State] {
    let groupedStates = Dictionary(grouping: container.states) { $0.name }
    let groupedStatesWithDaily = Dictionary(uniqueKeysWithValues: groupedStates.map { (stateName, snapshots) in
      (stateName,
      snapshots.enumerated().map { (index: Int, snapshot: StateSnapshot) -> StateSnapshot in
        guard let prevSnapshot = snapshots[safe: index - 1] else {
          return snapshot
        }
        return StateSnapshot(
          date: snapshot.date,
          name: snapshot.name,
          FIPS: snapshot.FIPS,
          totalCases: snapshot.totalCases,
          totalDeaths: snapshot.totalDeaths,
          dailyCases: snapshot.totalCases - prevSnapshot.totalCases,
          dailyDeaths: snapshot.totalDeaths - prevSnapshot.totalDeaths
        )
      })
    })

    let states = groupedStatesWithDaily.keys.map { State(name: $0, FIPS: groupedStatesWithDaily[$0]!.first!.FIPS, snapshots: groupedStatesWithDaily[$0]!) }
    return states
  }

  static func totalSnapshots(for states: [State]) -> [StateSnapshot] {
    let dates = states.compactMap { $0.snapshots.map { $0.date } }.flatMap { $0 }.uniques

    return dates
      .enumerated()
      .map { (offset: Int, date: Date) -> StateSnapshot in
        let totals = states
          .compactMap { $0.snapshots.first(where: { $0.date == date }) }
          .map { (totalCases: $0.totalCases, totalDeaths: $0.totalCases, dailyCases: $0.dailyCases, dailyDeaths: $0.dailyDeaths) }
          .reduce(into: (totalCases: 0, totalDeaths: 0, dailyCases: 0, dailyDeaths: 0), { result, snapshot in
            result.totalCases += snapshot.totalCases
            result.totalDeaths += snapshot.totalDeaths
            result.dailyCases += snapshot.dailyCases
            result.dailyDeaths += snapshot.dailyDeaths
          })
        return StateSnapshot(
          date: date,
          name: "United States Total",
          FIPS: 0,
          totalCases: totals.totalCases,
          totalDeaths: totals.totalDeaths,
          dailyCases: totals.dailyCases,
          dailyDeaths: totals.dailyDeaths
        )
    }
    .sorted()
  }

  static func keyedLines(from CSVData: Data) -> Data? {
    guard let dataString = String(data: CSVData, encoding: .utf8),
      let lines = .some(dataString.split(whereSeparator: { $0.isNewline })),
      let keys = lines.first?.split(separator: ",").map(String.init),
      let keyedLines = .some(lines[1...].map {
        Dictionary(uniqueKeysWithValues: zip(keys, $0.split(separator: ",")
          .map(String.init)))
      }),
      let results = try? JSONSerialization.data(withJSONObject: ["states" : keyedLines], options: []) else {
      return nil
    }
    return results
  }
}

// MARK: - Array extensions

private extension Array where Element: Hashable {
  var uniques: Array {
    var buffer = Array()
    var added = Set<Element>()
    for elem in self {
      if !added.contains(elem) {
        buffer.append(elem)
        added.insert(elem)
      }
    }
    return buffer
  }

  subscript(safe index: Int) -> Element? {
    guard index >= 0, index < endIndex else {
      return nil
    }

    return self[index]
  }

}
