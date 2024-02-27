//
//  MapViewController.swift
//  WeatherApp
//
//  Created by 이다연 on 2/23/24.
//

import UIKit
import MapKit

final class MapViewController: UIViewController, MKMapViewDelegate {
    var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MKMapView(frame: view.bounds)
        mapView.delegate = self
        view.addSubview(mapView)

        let overlay = WeatherTileOverlay()
        mapView.addOverlay(overlay, level: .aboveLabels)
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is WeatherTileOverlay {
            return MKTileOverlayRenderer(overlay: overlay)
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}
