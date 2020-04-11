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
      .tryMap { output in
        guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
          throw HTTPError.statusCode
        }
        guard let data = SnapshotsParser.keyedLines(from: output.data) else {
          throw HTTPError.parseCSV
        }
        return data
    }
    .decode(type: DataSnapshotContainer.self, decoder: JSONDecoder())
    .map(SnapshotsParser.updateLocations(for:))
    .map { SnapshotsParser.calculateDaily(with: $0, groupedBy: \.state) }
    .map { groupedStatesWithDaily in
      groupedStatesWithDaily.keys.map { State(name: $0, FIPS: groupedStatesWithDaily[$0]!.first!.FIPS, snapshots: groupedStatesWithDaily[$0]!) }
    }
    .eraseToAnyPublisher()
    .receive(on: DispatchQueue.main)
    .sink(receiveCompletion: { completion in
      switch completion {
      case .finished:
        break
      case .failure(let error):
        fatalError(error.localizedDescription)
      }
    }, receiveValue: { states in
      AppEnvironment.store.dispatch(.setStates(states))
      AppEnvironment.store.dispatch(.setTotal(SnapshotsParser.totalSnapshots(for: states)))
    })
    .store(in: &requests)
  }

  public func fetchCounties() {
    guard let url = URL(string: "https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv") else {
      fatalError("Unable to generate URL from counties CSV")
    }
    URLSession.shared.dataTaskPublisher(for: url)
      .tryMap { output in
        guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
          throw HTTPError.statusCode
        }
        guard let data = SnapshotsParser.keyedLines(from: output.data) else {
          throw HTTPError.parseCSV
        }
        return data
    }
    .decode(type: DataSnapshotContainer.self, decoder: JSONDecoder())
    .map(SnapshotsParser.updateLocations(for:))
    .map { SnapshotsParser.calculateDaily(with: $0, groupedBy: \.county) }
    .map { groupedCountiesWithDaily in
      groupedCountiesWithDaily.keys.map { County(name: $0, state: groupedCountiesWithDaily[$0]!.first!.county, FIPS: groupedCountiesWithDaily[$0]!.first!.FIPS, snapshots: groupedCountiesWithDaily[$0]!) }
    }
    .eraseToAnyPublisher()
    .receive(on: DispatchQueue.main)
    .sink(receiveCompletion: { completion in
      switch completion {
      case .finished:
        break
      case .failure(let error):
        fatalError(error.localizedDescription)
      }
    }, receiveValue: { counties in
      AppEnvironment.store.dispatch(.setCounties(counties))
    })
    .store(in: &requests)
  }
}
