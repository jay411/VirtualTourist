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
    var pages:Int?

    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }

     func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {

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
     func getImageUrls(_ parameters: [String:AnyObject], _ completionHandlerForGetImages: @escaping (_ success: Bool,_ imageArray:[Data]?,_ error: Error?)  -> Void) {

        let requestURL = URLRequest(url: flickrURLFromParameters(parameters))
        Alamofire.request(requestURL).validate().responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                if let pages = json["photos"]["pages"].int {
                    if pages == 0 {
                        var error:Error = NSError(domain: "no images", code: 1, userInfo: nil)
                        return completionHandlerForGetImages(true,nil,error)
                    }
                }
                if let pagesInt = json["photos"]["pages"].int {
                    self.pages = pagesInt
                    self.getImageUrlsFromPage(parameters, pagesInt, { (success,data,error) in
                        guard error == nil else {
                            return completionHandlerForGetImages(false,nil,error)
                        }
                        guard data != nil else{
                            var error:Error = NSError(domain: "no images", code: 1, userInfo: nil)
                            return completionHandlerForGetImages(false,nil,error)
                        }
                        if let imageData = data {
                            return completionHandlerForGetImages(true,imageData,nil)
                        }
                    })
                }
            case .failure(let error):
                return completionHandlerForGetImages(false,nil,error)
            }
        }
    }

     func getImageUrlsFromPage(_ parameters: [String:AnyObject],_ pages: Int,_ completionHandlerForGetFromPage: @escaping (_ success: Bool,_ imageArray:[Data]?, _ error:Error?) -> Void) {
        var newParameteres = parameters
        newParameteres[FlickrParameterKeys.page] = Int(arc4random_uniform(UInt32(pages))) as AnyObject
        print("random page",newParameteres[FlickrParameterKeys.page])
        var requestUrl = URLRequest(url: flickrURLFromParameters(newParameteres))
        requestUrl.timeoutInterval = 60
        Alamofire.request(requestUrl).responseJSON { (response) in
            switch response.result{
            case .failure(let error):
                print("network error")
                return completionHandlerForGetFromPage(false,nil,error)
            case .success(let value):
                let json = JSON(value)
                if let imageArray = self.createImageArray(json) {
                    return completionHandlerForGetFromPage(true,imageArray,nil)
                }
            }
        }
    }

    fileprivate func createImageArray(_ json:JSON) -> [Data]? {
        var i:Int = 0
        var imageDataArray:[Data] = []

        guard json[FlickrResponseKeys.Photos][FlickrResponseKeys.Photo].count != 0 else {
            return nil
        }
        if let photoArray = json[FlickrResponseKeys.Photos][FlickrResponseKeys.Photo].array {
            while i<40 && i<json[FlickrResponseKeys.Photos][FlickrResponseKeys.Photo].count {
                let imageJSON = photoArray[i]

                if let imageString = imageJSON[FlickrResponseKeys.MediumURL].string,let imageURL = URL(string: imageString) {

                    if let imageData = try? Data(contentsOf: imageURL) {
                    imageDataArray.append(imageData)
                    }
                }
                i+=1
            }
        }
        print("image data size",imageDataArray.count)
        return imageDataArray
    }

}
    // One request to get images

//        let imageURL = URL(string: imageString )
//        if let imageData = try? Data(contentsOf: imageURL!) {
//            self.iData = imageData
//        } else {
//            fatalError("Image does not exist at \(imageURL)")
//        }
