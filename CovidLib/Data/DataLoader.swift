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
        guard let data = StateParser.keyedLines(from: output.data) else {
           throw HTTPError.parseCSV
        }
        return data
    }
    .decode(type: StateSnapshotContainer.self, decoder: JSONDecoder())
    .map(StateParser.states(from:))
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
      AppEnvironment.store.dispatch(.setTotal(StateParser.totalSnapshots(for: states)))
    })
    .store(in: &requests)
  }
}
