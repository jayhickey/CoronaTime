//  
//  CoronaTime
//
//  Copyright © 2020 Jay Hickey. All rights reserved.
//

import Foundation
import Combine

public typealias Reducer = (inout AppState, AppAction) -> Void

public class Store: ObservableObject {
  @Published public internal(set) var value: AppState
  private let reducer: Reducer

  internal init(value: AppState, reducer: @escaping Reducer) {
    self.value = value
    self.reducer = reducer
  }

  public func dispatch(_ action: AppAction) {
    reducer(&value, action)
    PersistentStore.save(state: self.value)
  }
}
