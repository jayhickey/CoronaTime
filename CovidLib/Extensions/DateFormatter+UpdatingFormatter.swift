//  
//  Covid-19
//
//  Copyright © 2020 Jay Hickey. All rights reserved.
//

import Foundation

public extension DateFormatter {
  static var autoUpdatingFormatter: DateFormatter {
    let f = DateFormatter()
    f.calendar = .autoupdatingCurrent
    f.locale = .autoupdatingCurrent
    f.timeZone = .autoupdatingCurrent
    return f
  }
}
