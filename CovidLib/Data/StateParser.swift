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
    let states = groupedStates.keys.map { State(name: $0, FIPS: groupedStates[$0]!.first!.FIPS, snapshots: groupedStates[$0]!) }
    return states
  }

  static func totalSnapshots(for states: [State]) -> [StateSnapshot] {
    let dates = states.compactMap { $0.snapshots.map { $0.date } }.flatMap { $0 }.uniques

    return dates
      .map { (date: Date) -> StateSnapshot in
        let totals = states
          .compactMap { $0.snapshots.first(where: { $0.date == date }) }
          .map { (cases: $0.cases, deaths: $0.deaths) }
          .reduce(into: (cases: 0, deaths: 0), { result, snapshot in
            result.cases += snapshot.cases
            result.deaths += snapshot.deaths
          })
        return StateSnapshot(date: date, name: "United States Total", FIPS: 0, cases: totals.cases, deaths: totals.deaths)
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
}
