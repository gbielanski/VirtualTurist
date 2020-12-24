//
//  PhotosList.swift
//  VirtualTourist
//
//  Created by Grzegorz Bielanski on 21/12/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation

class PhotosList: Codable {
  let page, pages, perPage: Int
  let total: String
  let photos: [PhotoData]

  enum CodingKeys: String, CodingKey{
    case page
    case pages
    case perPage = "perpage"
    case total
    case photos = "photo"
  }
}
