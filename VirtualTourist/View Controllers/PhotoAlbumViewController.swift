//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Grzegorz Bielanski on 20/12/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController {

  let mapSettingsKey = "mapSettingsLey"

  @IBOutlet weak var mapView: MKMapView!
  var annotation: MKPointAnnotation?

  override func viewDidLoad() {
    super.viewDidLoad()
    mapView.delegate = self
    restoreMapPosition()
    if let annotation = annotation {
      mapView.addAnnotation(annotation)
    }
  }

}

extension PhotoAlbumViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    let reuseId = "pin"
    var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
    if pinView == nil {
      pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
      pinView!.canShowCallout = false
      pinView!.pinTintColor = .red
      pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
    }
    else {
      pinView!.annotation = annotation
    }
    return pinView
  }
}

extension PhotoAlbumViewController {
  func restoreMapPosition(){
    if let mapSettingsDictionary = UserDefaults.standard.object(forKey: mapSettingsKey) as? [String: Double]{
      let mapSettings = MapSettings.fromDictionary(dictionary: mapSettingsDictionary)
      let span = MKCoordinateSpan(latitudeDelta: mapSettings.latitudeDelta, longitudeDelta: mapSettings.longitudeDelta)
      let coordinate = CLLocationCoordinate2D(latitude: mapSettings.latitude, longitude: mapSettings.longitude)
      let region = MKCoordinateRegion(center: coordinate, span: span)
      mapView.setRegion(region, animated: false)
    }
  }
}
