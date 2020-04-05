//  
//  Covid-19
//
//  Copyright © 2020 Jay Hickey. All rights reserved.
//

import Foundation
import Combine

enum HTTPError: LocalizedError {
  case statusCode
  case parseCSV
}

public class DataLoader {
  private var requests: [AnyCancellable] = []

  // MARK: - Public

  public func fetchStates() {
    guard let url = URL(string: "https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-states.csv") else {
      fatalError("Unable to generate URL from states CSV")
    }
    URLSession.shared.dataTaskPublisher(for: url)
      .tryMap { [weak self] output in
        guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
          throw HTTPError.statusCode
        }
        guard let data = self?.keyedLines(from: output.data) else {
           throw HTTPError.parseCSV
        }
        return data
    }
    .decode(type: StateSnapshotContainer.self, decoder: JSONDecoder())
    .map(states(from:))
    .eraseToAnyPublisher()
    .receive(on: DispatchQueue.main)
    .sink(receiveCompletion: { completion in
      switch completion {
      case .finished:
        break
      case .failure(let error):
        fatalError(error.localizedDescription)
      }
    }, receiveValue: { [weak self] states in
      AppEnvironment.store.dispatch(.setStates(states))
      if let total = self?.totalSnapshots(for: states) {
        AppEnvironment.store.dispatch(.setTotal(total))
      }
    })
    .store(in: &requests)
  }

  // MARK: - Private

  private struct StateSnapshotContainer: Codable {
    let states: [StateSnapshot]
  }

  private func states(from container: StateSnapshotContainer) -> [State] {
    let groupedStates = Dictionary(grouping: container.states) { $0.name }
    let states = groupedStates.keys.map { State(name: $0, FIPS: groupedStates[$0]!.first!.FIPS, snapshots: groupedStates[$0]!) }
    return states
  }

  private func totalSnapshots(for states: [State]) -> [StateSnapshot] {
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

  private func keyedLines(from CSVData: Data) -> Data? {
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
