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

private class Annotation: NSObject, MKAnnotation {
  var coordinate: CLLocationCoordinate2D {
    return snapshot.location!.coordinate
  }

  let snapshot: DataSnapshot

  init(snapshot: DataSnapshot) {
    self.snapshot = snapshot
  }
}

private class AnnotationView: MKAnnotationView {

  var snapshot: DataSnapshot?

//  private var radius: CGFloat {
//    let value = CGFloat(number ?? 0)
//    return 10 + log( 1 + value) * CGFloat(mapZoomLevel - 2.2)
//  }

  private var containerView = UIView()

  private lazy var countLabel: UILabel = {
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

  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    translatesAutoresizingMaskIntoConstraints = false

    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(countLabel)

    NSLayoutConstraint.activate([
      countLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      countLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      countLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
      countLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
    ])

    addSubview(containerView)
    containerView.layoutIfNeeded()
    frame.size = CGSize(width: 200, height: 200)
  }

  required init?(coder aDecoder: NSCoder) {
    return nil
  }

  override func layoutSubviews() {
    super.layoutSubviews()
//    bounds = containerView.bounds
  }

  override func prepareForReuse() {
    super.layoutSubviews()
//    bounds = containerView.bounds
    countLabel.text = nil
  }

  override func prepareForDisplay() {
    if let snapshot = snapshot {
      countLabel.text = "\(snapshot.dailyDeaths)"
    }
    self.backgroundColor = .red
    containerView.layoutIfNeeded()
//    bounds = containerView.bounds
//    self.layer.cornerRadius = self.frame.width / 2
//
//    self.containerView.frame = self.frame
//    self.containerView.layer.cornerRadius = self.layer.cornerRadius
  }
}


class Coordinator: NSObject, MKMapViewDelegate {
  var parent: MapView

  init(_ parent: MapView) {
    self.parent = parent
  }

  func reloadAnnotations(on mapView: MKMapView, with snapshots: [DataSnapshot]) {
    mapView.removeAnnotations(mapView.annotations)

    mapView.addAnnotations(
      snapshots
        .filter { $0.location != nil }
        .map(Annotation.init)
    )
  }

  // MARK: - MKMapViewDelegate

  func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
    print(mapView.zoomLevel)
  }

  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    guard let annotation = annotation as? Annotation else { return nil }
    let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: String(describing: AnnotationView.self), for: annotation) as? AnnotationView

    annotationView?.snapshot = annotation.snapshot
    annotationView?.prepareForDisplay()
    return annotationView
  }

  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    print(view)
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
      AnnotationView.self,
      forAnnotationViewWithReuseIdentifier: String(describing: AnnotationView.self)
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
