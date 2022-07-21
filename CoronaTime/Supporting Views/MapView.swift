//  
//  CoronaTime
//
//  Copyright © 2020 Jay Hickey. All rights reserved.
//

import SwiftUI
import CoronaTimeLib
import MapKit

extension MKMapView {
  public static let maxZoom: CGFloat = 20
  public var zoomLevel: CGFloat {
    let zoomScale = self.visibleMapRect.size.width / Double(self.frame.size.width)
    let zoomExponent = log2(zoomScale)
    return Self.maxZoom - CGFloat(zoomExponent)
  }
}

private class SnapshotAnnotation: NSObject, MKAnnotation {
  var coordinate: CLLocationCoordinate2D {
    return snapshot.location!.coordinate
  }

  var radius: CGFloat = 0

  let snapshot: DataSnapshot

  init(snapshot: DataSnapshot) {
    self.snapshot = snapshot
  }

  override func isEqual(_ object: Any?) -> Bool {
    guard let object = object as? SnapshotAnnotation else { return false }
    return object.snapshot == snapshot && object.radius == radius
  }

  static func == (lhs: SnapshotAnnotation, rhs: SnapshotAnnotation) -> Bool {
    return lhs.snapshot == rhs.snapshot
      && lhs.radius == rhs.radius
  }
}

private class SnapshotAnnotationView: MKAnnotationView {

  private let containerView: UIView = {
    let container = UIView()
    container.backgroundColor = UIColor.red.withAlphaComponent(0.2)
    container.clipsToBounds = true
    container.translatesAutoresizingMaskIntoConstraints = false
    return container
  }()

  private let countLabel: UILabel = {
    let countLabel = UILabel()
    countLabel.translatesAutoresizingMaskIntoConstraints = false
    countLabel.backgroundColor = .clear
    countLabel.font = .boldSystemFont(ofSize: 13)
    countLabel.textColor = .white
    countLabel.textAlignment = .center
    countLabel.adjustsFontSizeToFitWidth = true
    countLabel.minimumScaleFactor = 0.5
    countLabel.baselineAdjustment = .alignCenters
    return countLabel
  }()

  private lazy var containerWidthAnchor = containerView.widthAnchor.constraint(equalToConstant: 10)
  private lazy var containerHeightAnchor = containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor)

  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

    addSubview(containerView)

    NSLayoutConstraint.activate([
      containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
      containerView.topAnchor.constraint(equalTo: topAnchor),
    ])
  }

  required init?(coder aDecoder: NSCoder) {
    return nil
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    invalidateIntrinsicContentSize()
    frame.size = intrinsicContentSize
  }

  override func prepareForReuse() {
    super.layoutSubviews()
    countLabel.text = nil
  }

  override func prepareForDisplay() {
    super.prepareForDisplay()
    if let annotation = annotation as? SnapshotAnnotation {
      countLabel.text = "\(annotation.snapshot.dailyDeaths)"
      containerWidthAnchor.constant = annotation.radius
      containerView.layer.cornerRadius = annotation.radius / 2
    }

    containerWidthAnchor.isActive = true
    containerHeightAnchor.isActive = true

    setNeedsLayout()
  }

  override var intrinsicContentSize: CGSize {
    let size = containerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    return size
  }
}


class Coordinator: NSObject, MKMapViewDelegate {
  var parent: MapView
  var snapshots: [DataSnapshot] = []

  init(_ parent: MapView) {
    self.parent = parent
  }

  func reloadAnnotations(on mapView: MKMapView, with snapshots: [DataSnapshot]) {
    self.snapshots = snapshots

    let newAnnotations = annotations(for: mapView.zoomLevel)
    if newAnnotations != mapView.annotations.compactMap({ $0 as? SnapshotAnnotation }) {
      mapView.removeAnnotations(mapView.annotations)
      mapView.addAnnotations(newAnnotations)
    }
  }

  // MARK: - MKMapViewDelegate

  func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
    print(mapView.zoomLevel)
    reloadAnnotations(on: mapView, with: snapshots)
  }

  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    guard annotation.isKind(of: SnapshotAnnotation.self) else { return nil }
    return mapView.dequeueReusableAnnotationView(withIdentifier: String(describing: SnapshotAnnotationView.self), for: annotation)
  }

  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    print(view)
  }

  private func annotations(for zoomLevel: CGFloat) -> [SnapshotAnnotation] {
    let annotations = snapshots
    .filter { $0.location != nil }
    .map(SnapshotAnnotation.init)

    switch zoomLevel {
    case _ where zoomLevel > 7:
      annotations
        .forEach { $0.radius = 50 }
    case _ where zoomLevel > 6:
      annotations
        .forEach { $0.radius = 30 }
    case _ where zoomLevel > 5:
      annotations
        .forEach { $0.radius = 10 }
    case _ where zoomLevel > 4:
      annotations
        .forEach { $0.radius = 5 }
    default:
      break
    }
    return annotations
  }
}

struct MapView: UIViewRepresentable {
  let snapshots: [DataSnapshot]

  init(snapshots: [DataSnapshot]) {
    self.snapshots = snapshots
  }

  func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
    let mapView = MKMapView()
    mapView.delegate = context.coordinator
    mapView.mapType = .mutedStandard
    mapView.register(
      SnapshotAnnotationView.self,
      forAnnotationViewWithReuseIdentifier: String(describing: SnapshotAnnotationView.self)
    )
    return mapView
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  func updateUIView(_ view: MKMapView, context: UIViewRepresentableContext<MapView>) {
    context.coordinator.reloadAnnotations(on: view, with: snapshots)
  }
}


struct MapView_Previews: PreviewProvider {
  static var previews: some View {
    MapView(snapshots: AppEnvironment.store.value.counties.compactMap { $0.snapshots.first })
      .edgesIgnoringSafeArea(.all)
  }
}
