//  
//  Covid-19
//
//  Copyright © 2020 Jay Hickey. All rights reserved.
//

import Foundation
import Combine

public typealias Reducer = (inout AppState, AppAction) -> Void

public class Store: ObservableObject {
  @Published public internal(set) var value: AppState
  private let reducer: Reducer

  private let saveQueue = DispatchQueue(label: "com.CovidLib.storeQueue")

  internal init(value: AppState, reducer: @escaping Reducer) {
    self.value = value
    self.reducer = reducer
  }

  public func dispatch(_ action: AppAction) {
    reducer(&value, action)
    saveQueue.async {
      PersistentStore.save(state: self.value)
    }
  }
}
