//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Grzegorz Bielanski on 21/12/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation

class FlickrClient {
  static var apiKey: String {
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

  static var apiSecret: String {
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

  enum Endpoints {
    static let base = "https://www.flickr.com/services/rest/"
    static let method = "flickr.photos.search"
    static let perPage = 30
    static let smallMediumImageSize = "url_m"
    static let radius = 30
    static var pageNumber : Int {
      get {
        return Int.random(in: 0..<10)
      }
    }

    case getPhotosList(String, String)

    var stringValue: String {
      switch self {
      case .getPhotosList(let latitude, let longitude): return Endpoints.base +
        "?method=\(Endpoints.method)" +
        "&api_key=\(FlickrClient.apiKey)" +
        "&lat=\(latitude)" +
        "&lon=\(longitude)" +
        "&per_page=\(Endpoints.perPage)" +
        "&page=\(Endpoints.pageNumber)" +
        "&extras=\(Endpoints.smallMediumImageSize)" +
        "&radius=\(Endpoints.radius)" +
        "&format=json&nojsoncallback=?"
      }
    }

    var url: URL {
      return URL(string: stringValue)!
    }
  }

  class func getPhotosList(lat: Double, lon: Double, completion: @escaping (PhotosList?, Error?) -> Void) {
    let url = Endpoints.getPhotosList("\(lat)", "\(lon)").url
    taskForGETRequest(url: url, responseType: GetPhotosListResponse.self){ (response, error)
      in
      if let response = response {
        completion(response.photos, nil)
      }else{
        completion(nil, error)
      }
    }
  }

  class func downloadPosterImage(path: String, completionHandler: @escaping (Data?, Error?) -> Void){

    if let url = URL(string: path) {
      let download = URLSession.shared.dataTask(with: url){ (data, _, error) in
        DispatchQueue.main.async {
          completionHandler(data, error)
        }
      }

      download.resume()
    }
  }

  class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void){
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
      guard let data = data else {
        DispatchQueue.main.async {
          completion(nil, error)
        }
        return
      }
      print(String(decoding: data, as: UTF8.self))
      let decoder = JSONDecoder()
      do {
        let responseObject = try decoder.decode(ResponseType.self, from: data)
        DispatchQueue.main.async {
          completion(responseObject, nil)
        }
      } catch {
        do {
          print(error.localizedDescription)
          let errorResponse = try decoder.decode(FlickrErrorResponse.self, from: data)
          DispatchQueue.main.async {
            completion(nil, errorResponse)
          }
        }catch{
          DispatchQueue.main.async {
            completion(nil, error)
          }
        }
      }
    }
    task.resume()
  }
}
