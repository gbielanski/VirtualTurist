//
//  MapSettings.swift
//  VirtualTourist
//
//  Created by Grzegorz Bielanski on 20/12/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation

struct MapSettings {
  let latitude: Double
  let longitude: Double
  let latitudeDelta: Double
  let longitudeDelta: Double
}

extension MapSettings {
  func toDictionary() -> [String:Double] {
    return [
      "latitude" : latitude,
      "longitude" : longitude,
      "latitudeDelta" : latitudeDelta,
      "longitudeDelta" : longitudeDelta,
    ]
  }

  static func fromDictionary(dictionary: [String:Double]) -> MapSettings{
    return MapSettings(
      latitude: dictionary["latitude"] ?? 0.0,
      longitude: dictionary["longitude"]  ?? 0.0,
      latitudeDelta: dictionary["latitudeDelta"]  ?? 0.0,
      longitudeDelta: dictionary["longitudeDelta"]  ?? 0.0
    )
  }
}
