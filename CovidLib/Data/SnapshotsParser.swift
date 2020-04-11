//  
//  Covid-19
//
//  Copyright © 2020 Jay Hickey. All rights reserved.
//

import Foundation
import CoreLocation
import Combine

class BundleClass {}

struct DataSnapshotContainer: Codable {
  let snapshots: [DataSnapshot]
}

var FIPSToCoord: [String: [String: Any]] = {
  guard let resourcePath = Bundle(for: BundleClass.self).path(forResource: "FIPS_to_coord", ofType: "json"),
    let data = try? JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: resourcePath)), options: []) as? [String: [String: Any]] else {
      return [:]
  }
  return data
}()

enum SnapshotsParser {
  static func calculateDaily(with container: DataSnapshotContainer, groupedBy keyPath: KeyPath<DataSnapshot, String>) -> [String : [DataSnapshot]] {
    let groupedStates = Dictionary(grouping: container.snapshots) { $0[keyPath: keyPath] }
    return Dictionary(uniqueKeysWithValues: groupedStates.map { (stateName, snapshots) in
      (stateName,
      snapshots.enumerated().map { (index: Int, snapshot: DataSnapshot) -> DataSnapshot in
        guard let prevSnapshot = snapshots[safe: index - 1] else {
          return snapshot
        }
        return DataSnapshot(
          date: snapshot.date,
          state: snapshot.state,
          county: snapshot.county,
          FIPS: snapshot.FIPS,
          totalCases: snapshot.totalCases,
          totalDeaths: snapshot.totalDeaths,
          dailyCases: snapshot.totalCases - prevSnapshot.totalCases,
          dailyDeaths: snapshot.totalDeaths - prevSnapshot.totalDeaths
        )
      })
    })
  }

  static func updateLocations(for container: DataSnapshotContainer) -> DataSnapshotContainer {
    return DataSnapshotContainer(
      snapshots: container.snapshots
        .map { snapshot -> DataSnapshot in
          guard let dataLocation = FIPSToCoord[String(snapshot.FIPS)],
            let latitude = dataLocation["lat"] as? Double,
            let longitude = dataLocation["long"] as? Double else { return snapshot }
          var mutableSnapshot = snapshot
          mutableSnapshot.location = Location(latitude: latitude, longitude: longitude)
          return mutableSnapshot
      }
    )
  }

  static func totalSnapshots(for states: [State]) -> [DataSnapshot] {
    let dates = states.compactMap { $0.snapshots.map { $0.date } }.flatMap { $0 }.uniques

    return dates
      .enumerated()
      .map { (offset: Int, date: Date) -> DataSnapshot in
        let totals = states
          .compactMap { $0.snapshots.first(where: { $0.date == date }) }
          .map { (totalCases: $0.totalCases, totalDeaths: $0.totalDeaths, dailyCases: $0.dailyCases, dailyDeaths: $0.dailyDeaths) }
          .reduce(into: (totalCases: 0, totalDeaths: 0, dailyCases: 0, dailyDeaths: 0), { result, snapshot in
            result.totalCases += snapshot.totalCases
            result.totalDeaths += snapshot.totalDeaths
            result.dailyCases += snapshot.dailyCases
            result.dailyDeaths += snapshot.dailyDeaths
          })
        return DataSnapshot(
          date: date,
          state: "United States",
          county: "N/A",
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
      let results = try? JSONSerialization.data(withJSONObject: ["snapshots" : keyedLines], options: []) else {
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
