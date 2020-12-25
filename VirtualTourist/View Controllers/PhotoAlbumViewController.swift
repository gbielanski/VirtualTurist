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

  //var annotation: MKPointAnnotation?
  var pin: Pin?

  var fetchedResultsController: NSFetchedResultsController<Photo>!

  @IBAction func newCollectionButtonTapped(_ sender: Any) {
    let photos = fetchedResultsController.fetchedObjects
    photos?.forEach{ photo in
      dataController.viewContext.delete(photo)
      try? dataController.viewContext.save()
    }
    downloadPhotos()
  }

  func pinToAnnotation(pin: Pin) -> MKPointAnnotation {
    let a = MKPointAnnotation()
    a.coordinate.longitude = pin.longitude
    a.coordinate.latitude = pin.latitude
    return a
  }

  fileprivate func setupFetchedResultController() {
    let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()

    let predicate = NSPredicate(format: "pin == %@", pin!)
    fetchRequest.sortDescriptors = []
    fetchRequest.predicate = predicate

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
    mapView.addAnnotation(pinToAnnotation(pin: pin!))


    imagesVisiblility(visible: false)
    newCollectionButton.isEnabled = false

    setupFetchedResultController()

    if fetchedResultsController.sections?[0].numberOfObjects ?? 0 > 0 {
      imagesVisiblility(visible: true)
      newCollectionButton.isEnabled = true
      collectionView.reloadData()
    } else {
      downloadPhotos()
    }
  }

  func downloadPhotos(){
    if let lat = pin?.latitude, let lon = pin?.longitude {
      FlickrClient.getPhotosList(lat: lat, lon: lon, completion: handleGetPhotosList(photos:error:))
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
      let photo = Photo(context: self.dataController.viewContext)
      photo.path = photoData.url
      photo.image = nil
      photo.pin = pin
      try? self.dataController.viewContext.save()
    }

    photos?.photos.forEach{photoData in
      FlickrClient.downloadPosterImage(path: photoData.url){
        (data, error) in
        guard let data = data else {
          return
        }

        self.fetchedResultsController.sections?[0].objects?.forEach{ photoObject in

          let photo = photoObject as! Photo
          if photo.path == photoData.url {
            photo.image = data
            try? self.dataController.viewContext.save()
          }
        }
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

    cell.photoImage?.image = getImage(photo: photo)
    cell.setNeedsLayout()

    return cell
  }

  func getImage(photo: Photo) -> UIImage {
    if let imageData = photo.image {
      return UIImage(data: imageData)!
    }else{
      return UIImage(named: "placeholder")!
    }
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return fetchedResultsController.sections?[0].numberOfObjects ?? 0
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let photo = fetchedResultsController.object(at: indexPath as IndexPath)
    dataController.viewContext.delete(photo)
    try? dataController.viewContext.save()
  }
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate{

  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

    switch type {
    case .insert:
      collectionView.insertItems(at: [newIndexPath!])
      break
    case .delete:
      collectionView.deleteItems(at: [indexPath!])
      break
    case .update:
      collectionView.reloadItems(at: [indexPath!])
      break
    case .move:
      break
    @unknown default:
      break
    }
  }
}
