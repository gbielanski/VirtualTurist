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
    
    let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
    mapView.addGestureRecognizer(longPressRecognizer)
  }
  
  @objc func longPressed(gestureRecognizer: UILongPressGestureRecognizer) {
    if gestureRecognizer.state == .ended {
      let touchPoint = gestureRecognizer.location(in: mapView)
      let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
      let annotation = MKPointAnnotation()
      annotation.coordinate = newCoordinates
      mapView.addAnnotation(annotation)
      print("\(newCoordinates)")
    }
  }
}

extension TravelLocationMapViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool){
    let mapSettings = MapSettings(latitude: mapView.region.center.latitude, longitude: mapView.region.center.longitude, latitudeDelta: mapView.region.span.latitudeDelta, longitudeDelta: mapView.region.span.longitudeDelta)
    UserDefaults.standard.set(mapSettings.toDictionary(), forKey: mapSettingsKey)
  }
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    let reuseId = "pin"
    var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
    if pinView == nil {
      pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
      pinView!.canShowCallout = true
      pinView!.pinTintColor = .red
      pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
    }
    else {
      pinView!.annotation = annotation
    }
    return pinView
  }
  
}

extension TravelLocationMapViewController {
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

