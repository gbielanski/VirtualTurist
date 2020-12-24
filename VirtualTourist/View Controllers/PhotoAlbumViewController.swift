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
import CoreData
class PhotoAlbumViewController: UIViewController {

  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var newCollectionButton: UIButton!
  @IBOutlet weak var noImagesLabel: UILabel!

  var dataController: DataController!

  var annotation: MKPointAnnotation?

  var fetchedResultsController: NSFetchedResultsController<Photo>!

  fileprivate func setupFetchedResultController() {
    let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
    fetchRequest.sortDescriptors = []

    fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "photos")
    fetchedResultsController.delegate = self
    do {
      try fetchedResultsController.performFetch()
    } catch{
      fatalError("The fetch could not be performed \(error.localizedDescription)")
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    mapView.delegate = self
    collectionView.dataSource = self
    collectionView.delegate = self
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    restoreMapPosition(mapView: mapView)
    if let annotation = annotation {
      mapView.addAnnotation(annotation)
    }

    imagesVisiblility(visible: false)
    newCollectionButton.isEnabled = false

    setupFetchedResultController()

    if fetchedResultsController.sections?.count ?? 0 > 0 {
      if fetchedResultsController.sections?[0].numberOfObjects ?? 0 > 0 {
        imagesVisiblility(visible: true)
        newCollectionButton.isEnabled = true
        collectionView.reloadData()
      }
    } else {
      if let lat = annotation?.coordinate.latitude, let lon = annotation?.coordinate.latitude {
        FlickrClient.getPhotosList(lat: lat, lon: lon, completion: handleGetPhotosList(photos:error:))
      }
    }
  }
  

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    fetchedResultsController = nil
  }

  func handleGetPhotosList(photos: PhotosList?, error: Error?){
    if let error = error {
      print(error.localizedDescription)
      self.imagesVisiblility(visible: false)
      
    }

    self.newCollectionButton.isEnabled = true

    photos?.photos.forEach{photoData in
      FlickrClient.downloadPosterImage(path: photoData.url){
        (data, error) in
        guard let data = data else {
          return
        }

        let photo = Photo(context: self.dataController.viewContext)
        photo.path = photoData.url
        photo.image = data
        try? self.dataController.viewContext.save()
      }
    }

    if (Int(photos?.total ?? "0") ?? 0) > 0 {
      self.imagesVisiblility(visible: true)
      self.collectionView.reloadData()
    }
  }

  func imagesVisiblility(visible: Bool){
    collectionView.isHidden = !visible
    noImagesLabel.isHidden = visible
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
    let photo = fetchedResultsController.object(at: indexPath)
    let image = UIImage(data: photo.image!)
    cell.photoImage?.image = image
    cell.setNeedsLayout()

      return cell
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return fetchedResultsController.sections?[0].numberOfObjects ?? 0

  }
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate{

  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

    switch type {
    case .insert:
      collectionView.insertItems(at: [newIndexPath!])
      break
    case .delete:
      break
    case .update:
      break
    case .move:
      break
    @unknown default:
      break
    }
  }
}
