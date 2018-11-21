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
        let url = flickrURLFromParameters(parameters)
        Alamofire.request(url).responseJSON { (response) in
            switch response.result {
            case .success:
                (print("success"))
            case .failure (let error):
                (print(error.localizedDescription))
            }
        }
    }
    // One request to get images
}
