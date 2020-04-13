//  
//  CoronaTime
//
//  Copyright © 2020 Jay Hickey. All rights reserved.
//

import SwiftUI

struct MultipleSelectionRow: View {
  var title: String
  var subtitle: String
  var isSelected: Bool
  var action: () -> Void
  
  var body: some View {
    Button(action: self.action) {
      HStack {
        VStack(alignment: .leading) {
          Text(self.title)
            .foregroundColor(Color(.label))
          Text(self.subtitle)
            .foregroundColor(Color(.secondaryLabel))
            .font(.caption)
        }
        Spacer()
        if self.isSelected {
          Image(systemName: "checkmark")
        }
      }
    }
  }
}
