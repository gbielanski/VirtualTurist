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

  @IBOutlet weak var mapView: MKMapView!
  var annotation: MKPointAnnotation?

  override func viewDidLoad() {
    super.viewDidLoad()
    mapView.delegate = self
    restoreMapPosition(mapView: mapView)
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
