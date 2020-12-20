//
//  TravelLocationMapViewController.swift
//  VirtualTourist
//
//  Created by Grzegorz Bielanski on 18/12/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationMapViewController: UIViewController {

  let mapSettingsKey = "mapSettingsLey"

  @IBOutlet weak var mapView: MKMapView!

  override func viewDidLoad() {
    super.viewDidLoad()
    restoreMapPosition()
    mapView.delegate = self
  }

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

extension TravelLocationMapViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool){
    let mapSettings = MapSettings(latitude: mapView.region.center.latitude, longitude: mapView.region.center.longitude, latitudeDelta: mapView.region.span.latitudeDelta, longitudeDelta: mapView.region.span.longitudeDelta)
    UserDefaults.standard.set(mapSettings.toDictionary(), forKey: mapSettingsKey)
  }
}

