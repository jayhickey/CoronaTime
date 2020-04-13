//  
//  CoronaTime
//
//  Copyright © 2020 Jay Hickey. All rights reserved.
//

import Foundation

public let AppEnvironment = (
  store: Store(value: PersistentStore.load() ?? AppState(), reducer: appReducer),
  dataLoader: DataLoader()
)
