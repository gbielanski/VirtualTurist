//
//  TravelLocationMapViewController.swift
//  VirtualTourist
//
//  Created by Grzegorz Bielanski on 18/12/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationMapViewController: UIViewController, MKMapViewDelegate {

  @IBOutlet weak var mapView: MKMapView!
  override func viewDidLoad() {
    super.viewDidLoad()
    mapView.delegate = self
    // Do any additional setup after loading the view.
  }

  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool){
    print(
      """
      regionDidChange
      \(mapView.region.center.latitude)
      \(mapView.region.center.longitude)
      \(mapView.region.span.latitudeDelta)
      \(mapView.region.span.latitudeDelta)
      """)
  }


}

