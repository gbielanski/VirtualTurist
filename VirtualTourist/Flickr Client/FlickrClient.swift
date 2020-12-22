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
    static let perPage = 10
    static let smallMediumImageSize = "url_m"
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
        "&format=json&nojsoncallback=?"
      }
    }

    var url: URL {
      return URL(string: stringValue)!
    }
  }

  class func getPhotosList(lat: Double, lon: Double, completion: @escaping (PhotosList?, Error?) -> Void) -> URLSessionTask {
    print("Api key \(FlickrClient.apiKey)")
    let url = Endpoints.getPhotosList("\(lat)", "\(lon)").url
    print("url \(url)")
    let task = taskForGETRequest(url: url, responseType: GetPhotosListResponse.self){ (response, error)
      in
      if let response = response {
        print("response")
        completion(response.photos, nil)
      }else{
        completion(nil, error)
        print("reponse error")
      }
    }

    return task
  }

  @discardableResult class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask{
    let url1 = URL(string: "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=cc074c0cfe1f5f0d69b85cdf6b05442f&lat=52.25164625673966&lon=21.052382403498882&radius=20&per_page=15&page=0&format=json&nojsoncallback=1&extras=url_m")!
    let task = URLSession.shared.dataTask(with: url1) { data, response, error in
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
          print("errorResponse")
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
    return task
  }
}
