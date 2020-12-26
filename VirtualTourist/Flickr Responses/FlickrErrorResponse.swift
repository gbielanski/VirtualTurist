//
//  FlickrErrorResponse.swift
//  VirtualTourist
//
//  Created by Grzegorz Bielanski on 21/12/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation

class FlickrErrorResponse: Codable {
  let stat: String
  let code: Int
  let message: String
  
  enum CodingKeys: String, CodingKey{
    case stat
    case code
    case message
  }
}

extension FlickrErrorResponse : LocalizedError{
  var errorDescription: String? {
    return message
  }
}
