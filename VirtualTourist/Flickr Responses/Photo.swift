//
//  Photo.swift
//  VirtualTourist
//
//  Created by Grzegorz Bielanski on 21/12/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation

//{
//"id":"50733632262",
//"owner":"166781394@N05",
//"secret":"ec39a716f3",
//"server":"65535",
//"farm":66,
//"title":"0102",
//"ispublic":1,
//"isfriend":0,
//"isfamily":0,
//"url_m":"https:\/\/live.staticflickr.com\/65535\/50733632262_ec39a716f3.jpg",
//"height_m":"500",
//"width_m":"266"
//}

class Photo: Codable {
  let id: String
  let owner: String
  let secret: String
  let server: String
  let farm: Int
  let title: String
  let isPublic: Int
  let isFriend: Int
  let isFamily: Int
  let url: String
  let height: String
  let width: String

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
