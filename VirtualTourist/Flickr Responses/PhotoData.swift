//
//  Photo.swift
//  VirtualTourist
//
//  Created by Grzegorz Bielanski on 21/12/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation

class PhotoData: Codable {
  let id, owner, secret, server: String
  let farm: Int
  let title: String
  let isPublic, isFriend, isFamily: Int
  let url: String
  let height, width: Int
  
  enum CodingKeys: String, CodingKey{
    case id
    case owner
    case secret
    case server
    case farm
    case title
    case isPublic = "ispublic"
    case isFriend = "isfriend"
    case isFamily = "isfamily"
    case url = "url_m"
    case height = "height_m"
    case width = "width_m"
  }
}
