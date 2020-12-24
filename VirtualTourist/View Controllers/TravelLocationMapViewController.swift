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

  @IBOutlet weak var mapView: MKMapView!

  var dataController: DataController!

  var fetchedResultsController: NSFetchedResultsController<Pin>!


  fileprivate func setupFetchedResultController() {
    let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
    let sortDespriptor = NSSortDescriptor(key: "latitude", ascending: false)
    fetchRequest.sortDescriptors = [sortDespriptor]

    fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pins")
    fetchedResultsController.delegate = self
    do {
      try fetchedResultsController.performFetch()
    } catch{
      fatalError("The fetch could not be performed \(error.localizedDescription)")
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    restoreMapPosition(mapView: mapView)
    mapView.delegate = self

    let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
    mapView.addGestureRecognizer(longPressRecognizer)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setupFetchedResultController()
    getAllSevadPins()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    fetchedResultsController = nil
  }

  func getAllSevadPins(){
    if fetchedResultsController.sections?.count ?? 0 > 0 {
      if fetchedResultsController.sections?[0].numberOfObjects ?? 0 > 0 {
        fetchedResultsController.sections?[0].objects?.forEach{pinObject in
          let annotation = pinObject2MKPointAnnotation(pinObject)
          mapView.addAnnotation(annotation)
        }
      }
    }
  }

  @objc func longPressed(gestureRecognizer: UILongPressGestureRecognizer) {
    if gestureRecognizer.state == .ended {
      let touchPoint = gestureRecognizer.location(in: mapView)
      let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)

      let pin = Pin(context: dataController.viewContext)
      pin.latitude = newCoordinates.latitude
      pin.longitude = newCoordinates.longitude
      try? dataController.viewContext.save()
    }
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showPhotoAlbum" {
      let photoAlbymVC = segue.destination as! PhotoAlbumViewController
      let annotation = sender as! MKPointAnnotation
      photoAlbymVC.annotation = annotation
    }
  }
}

extension TravelLocationMapViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool){
    let mapSettings = MapSettings(latitude: mapView.region.center.latitude, longitude: mapView.region.center.longitude, latitudeDelta: mapView.region.span.latitudeDelta, longitudeDelta: mapView.region.span.longitudeDelta)
    UserDefaults.standard.set(mapSettings.toDictionary(), forKey: getMapSettingsKey())
  }

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

  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    print("Pin tapped")
    if let annotation = view.annotation as? MKPointAnnotation {
      self.performSegue(withIdentifier: "showPhotoAlbum", sender: annotation)
    }
  }
}

extension TravelLocationMapViewController: NSFetchedResultsControllerDelegate{

  func pinObject2MKPointAnnotation(_ anObject: Any) -> MKPointAnnotation{
    let pin = anObject as! Pin
    let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
    let annotation = MKPointAnnotation()
    annotation.coordinate = coordinate

    return annotation
  }

  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

    let annotation = pinObject2MKPointAnnotation(anObject)
    switch type {
    case .insert:
      mapView.addAnnotation(annotation)
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

