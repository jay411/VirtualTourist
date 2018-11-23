//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by jay raval on 11/14/18.
//  Copyright © 2018 jay raval. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class FlickrClient {
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }

    private func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {

        var components = URLComponents()
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        components.path = Constants.ApiPath
        
        components.queryItems = [URLQueryItem]()
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }

        return components.url!
    }
    // One request to get photos dictionary
    func getImageUrls(_ parameters: [String:AnyObject], _ completionHandlerForGetImages: @escaping (_ success: Bool,_ error: Error?)  -> Void) {

        let requestURL = URLRequest(url: flickrURLFromParameters(parameters))
        print(requestURL)
        Alamofire.request(requestURL).validate().responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json["photos"]["photo"][0][FlickrResponseKeys.MediumURL])

            case .failure(let error):
                print("error",error.localizedDescription)
            }
        }

    }
    // One request to get images
}
