//
//  GetPhotosListResponse.swift
//  VirtualTourist
//
//  Created by Grzegorz Bielanski on 21/12/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation

class GetPhotosListResponse: Codable {
  let photos : PhotosList
  let stat: String
}
