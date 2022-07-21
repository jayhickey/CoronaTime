//  
//  CoronaTime
//
//  Copyright © 2020 Jay Hickey. All rights reserved.
//

import SwiftUI
import Charts
import CoronaTimeLib

struct ChartView: UIViewRepresentable {
  let states: [[DataSnapshot]]
  let type: ChartType
  let onValueDeselected: () -> Void
  let onValueSelected: (ChartDataEntry) -> Void

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  func makeUIView(context: Context) -> LineChartView {
    let chart = LineChartView()
    chart.delegate = context.coordinator

    chart.legend.form = .line
    chart.legend.textColor = .label

    chart.drawGridBackgroundEnabled = false

    chart.xAxis.labelPosition = .bottom
    chart.xAxis.labelTextColor = .label
    chart.xAxis.drawGridLinesEnabled = false
    chart.xAxis.valueFormatter = DateValueFormatter(formatter: {
      let f = DateFormatter.autoUpdatingFormatter
      f.dateStyle = .short
      return f
    }())

    chart.leftAxis.drawLabelsEnabled = false
    chart.leftAxis.drawAxisLineEnabled = false
    chart.leftAxis.drawGridLinesEnabled = false

    chart.rightAxis.labelTextColor = .label
    chart.rightAxis.gridColor = .separator
    chart.rightAxis.valueFormatter = LargeValueFormatter()
    
    return chart
  }

  func updateUIView(_ chart: LineChartView, context: Context) {
    chart.animate(xAxisDuration: 0.1)

    let coloredDataSet = dataSets(for: states, type: type)
      .enumerated()
      .compactMap { (index: Int, element: LineChartDataSet) -> LineChartDataSet? in
        let newValue = element.copy() as? LineChartDataSet
        newValue?.setColor(chartColors[index % chartColors.count])
        return newValue
    }

    // Clear any user selections / highlights
    chart.highlightValues(nil)
    if !chart.valuesToHighlight() {
      onValueDeselected()
    }

    chart.data = LineChartData(dataSets: coloredDataSet)
  }

  class Coordinator: NSObject, ChartViewDelegate {
    var parent: ChartView

    init(_ chartView: ChartView) {
      self.parent = chartView
    }

    // MARK: - ChartViewDelegate

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
      parent.onValueSelected(entry)
    }

    func chartValueNothingSelected(_ chartView: ChartViewBase) {
      parent.onValueDeselected()
    }
  }
}

extension ChartView: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.states == rhs.states && lhs.type == rhs.type
  }
}

private func dataSets(for states: [[DataSnapshot]], type: ChartType) -> [LineChartDataSet] {
  states
    .map { state in
      let dataSet = LineChartDataSet(
        entries: state.map {
          ChartDataEntry(
            x: $0.date.timeIntervalSince1970,
            y: Double($0.count(for: type))
          )
        },
        label: state.first?.state ?? ""
      )
      dataSet.mode = .linear

      dataSet.drawCirclesEnabled = false
      dataSet.drawValuesEnabled = false

      dataSet.highlightColor = .systemGray
      dataSet.highlightLineWidth = 2.0
      dataSet.highlightLineDashPhase = 0.1
      dataSet.highlightLineDashLengths = [4]
      dataSet.lineWidth = 1

      return dataSet
  }
}

private let chartColors = [
  UIColor(rgb: 0x3498db),
  UIColor(rgb: 0x2ecc71),
  UIColor(rgb: 0x9b59b6),
  UIColor(rgb: 0xf1c40f),
  UIColor(rgb: 0xe67e22),
  UIColor(rgb: 0xe74c3c),
  UIColor(rgb: 0x1abc9c),
  UIColor(rgb: 0x34495e),

  UIColor(rgb: 0x2980b9),
  UIColor(rgb: 0x27ae60),
  UIColor(rgb: 0x8e44ad),
  UIColor(rgb: 0xf39c12),
  UIColor(rgb: 0xd35400),
  UIColor(rgb: 0xc0392b),
  UIColor(rgb: 0x16a085),
  UIColor(rgb: 0x2c3e50)
]

private final class DateValueFormatter: IndexAxisValueFormatter {
  override func stringForValue(_ value: Double, axis: AxisBase?) -> String {
    return formatter.string(from: Date(timeIntervalSince1970: value))
  }

  let formatter: DateFormatter

  init(formatter: DateFormatter) {
    self.formatter = formatter
    super.init()
  }
}

private final class LargeValueFormatter: IndexAxisValueFormatter {

  /// Suffix to be appended after the values.
  ///
  /// **default**: suffix: ["", "k", "m", "b", "t"]
  private var suffix = ["", "k", "m", "b", "t"]

  /// An appendix text to be added at the end of the formatted value.
  private var appendix: String?

  fileprivate init(appendix: String? = nil) {
    self.appendix = appendix
    super.init()
  }

  fileprivate func format(value: Double) -> String {
    var sig = value
    var length = 0
    let maxLength = suffix.count - 1

    while sig >= 1000.0 && length < maxLength {
      sig /= 1000.0
      length += 1
    }

    var r = String(format: "%2.f", sig) + suffix[length]

    if let appendix = appendix {
      r += appendix
    }

    return r
  }

  fileprivate override func stringForValue(_ value: Double, axis: AxisBase?) -> String {
    return format(value: value)
  }

  fileprivate func stringForValue(
    _ value: Double,
    entry: ChartDataEntry,
    dataSetIndex: Int,
    viewPortHandler: ViewPortHandler?) -> String {
    return format(value: value)
  }
}
