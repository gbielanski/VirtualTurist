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

  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var mapView: MKMapView!
  var annotation: MKPointAnnotation?
  var photos: [Photo]? = nil

  override func viewDidLoad() {
    super.viewDidLoad()
    mapView.delegate = self
    collectionView.dataSource = self
    collectionView.delegate = self
    restoreMapPosition(mapView: mapView)
    if let annotation = annotation {
      mapView.addAnnotation(annotation)
    }

    imagesVisiblility(visible: false)

    if let lat = annotation?.coordinate.latitude, let lon = annotation?.coordinate.latitude {
      FlickrClient.getPhotosList(lat: lat, lon: lon){ (photos, error) in

        if let error = error {
          print(error.localizedDescription)
          self.imagesVisiblility(visible: false)
        }

        self.photos = photos?.photos

        if (Int(photos?.total ?? "0") ?? 0) > 0 {
          self.imagesVisiblility(visible: true)
          self.collectionView.reloadData()
        }
      }
    }
  }

  func imagesVisiblility(visible: Bool){
    collectionView.isHidden = !visible
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

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
    let photo = photos![(indexPath as NSIndexPath).row]
    cell.photoImage.image = UIImage(named: "placeholder")
    FlickrClient.downloadPosterImage(path: photo.url){
      (data, error) in
      guard let data = data else {
        return
      }

      let image = UIImage(data: data)
      cell.photoImage?.image = image
      cell.setNeedsLayout()
    }

    return cell
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.photos?.count ?? 0
  }
}
