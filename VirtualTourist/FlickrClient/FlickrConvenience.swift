//
//  FlickrConvenience.swift
//  VirtualTourist
//
//  Created by jay raval on 11/21/18.
//  Copyright © 2018 jay raval. All rights reserved.
//

import Foundation
import CoreLocation

extension FlickrClient {

    func getImagesForPoint(_ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees, _ completionHandlerForGet: @escaping(_ success: Bool,_ imageArray:[Data]?, _ error: Error?) -> Void) {
        let methodParameters = [
            FlickrParameterKeys.Method: FlickrParameterValues.SearchMethod,
            FlickrParameterKeys.APIKey: FlickrParameterValues.APIKey,
            FlickrParameterKeys.BoundingBox: bboxString(latitude, longitude),
            FlickrParameterKeys.SafeSearch: FlickrParameterValues.UseSafeSearch,
            FlickrParameterKeys.Extras: FlickrParameterValues.MediumURL,
            FlickrParameterKeys.Format: FlickrParameterValues.ResponseFormat,
            FlickrParameterKeys.NoJSONCallback: FlickrClient.FlickrParameterValues.DisableJSONCallback
        ]
        self.getImageUrls(methodParameters as [String:AnyObject]) { success, data, error in
            guard error == nil else {
                return completionHandlerForGet(false,nil,error)
            }
            guard data != nil else {
                let error:Error = NSError(domain: "no images found", code: 1, userInfo: nil)
                return completionHandlerForGet(false,nil,error)
            }
            return completionHandlerForGet(success,data,nil)
        }
    }
    private func bboxString(_ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees) -> String {
        // ensure bbox is bounded by minimum and maximums
                let minimumLon = max(longitude - FlickrClient.Constants.SearchBBoxHalfWidth, FlickrClient.Constants.SearchLonRange.0)
            let minimumLat = max(latitude - FlickrClient.Constants.SearchBBoxHalfHeight, FlickrClient.Constants.SearchLatRange.0)
            let maximumLon = min(longitude + FlickrClient.Constants.SearchBBoxHalfWidth, FlickrClient.Constants.SearchLonRange.1)
            let maximumLat = min(latitude + FlickrClient.Constants.SearchBBoxHalfHeight, FlickrClient.Constants.SearchLatRange.1)
            return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
        }


    
}
