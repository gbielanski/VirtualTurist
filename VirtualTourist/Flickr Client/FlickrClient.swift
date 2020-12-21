//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Grzegorz Bielanski on 21/12/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation

private var apiKey: String {
  get {
    guard let filePath = Bundle.main.path(forResource: "Flickr-Info", ofType: "plist") else {
      fatalError("Couldn't find file 'Flickr-Info.plist'.")
    }
    let plist = NSDictionary(contentsOfFile: filePath)
    guard let value = plist?.object(forKey: "API_KEY") as? String else {
      fatalError("Couldn't find key 'API_KEY' in 'Flickr-Info.plist'.")
    }
    return value
  }
}

private var apiSecret: String {
  get {
    guard let filePath = Bundle.main.path(forResource: "Flickr-Info", ofType: "plist") else {
      fatalError("Couldn't find file 'Flickr-Info.plist'.")
    }
    let plist = NSDictionary(contentsOfFile: filePath)
    guard let value = plist?.object(forKey: "API_SECRET") as? String else {
      fatalError("Couldn't find key 'API_SECRET' in 'Flickr-Info.plist'.")
    }
    return value
  }
}
