//
//  ViewController+Extensions.swift
//  VirtualTourist
//
//  Created by Grzegorz Bielanski on 20/12/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation
import UIKit
import MapKit

extension UIViewController {
  func getMapSettingsKey() -> String {
    return "mapSettingsLey"
  }
  
  func restoreMapPosition(mapView: MKMapView){
    if let mapSettingsDictionary = UserDefaults.standard.object(forKey: getMapSettingsKey()) as? [String: Double]{
      let mapSettings = MapSettings.fromDictionary(dictionary: mapSettingsDictionary)
      let span = MKCoordinateSpan(latitudeDelta: mapSettings.latitudeDelta, longitudeDelta: mapSettings.longitudeDelta)
      let coordinate = CLLocationCoordinate2D(latitude: mapSettings.latitude, longitude: mapSettings.longitude)
      let region = MKCoordinateRegion(center: coordinate, span: span)
      mapView.setRegion(region, animated: false)
    }
  }
}
