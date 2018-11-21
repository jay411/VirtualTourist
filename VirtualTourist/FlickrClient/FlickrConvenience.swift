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

    func getImagesForPoint(_ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees, _ completionHandlerForGet: @escaping(_ success: Bool, _ error: Error?) -> Void) {
        let methodParameters = [
            FlickrClient.FlickrParameterKeys.Method: FlickrClient.FlickrParameterValues.SearchMethod,
            FlickrClient.FlickrParameterKeys.APIKey: FlickrClient.FlickrParameterValues.APIKey,
            FlickrClient.FlickrParameterKeys.BoundingBox: bboxString(latitude,longitude),
            FlickrClient.FlickrParameterKeys.SafeSearch: FlickrClient.FlickrParameterValues.UseSafeSearch,
            FlickrClient.FlickrParameterKeys.Extras: FlickrClient.FlickrParameterValues.MediumURL,
            FlickrClient.FlickrParameterKeys.Format: FlickrClient.FlickrParameterValues.ResponseFormat,
            FlickrClient.FlickrParameterKeys.NoJSONCallback: FlickrClient.FlickrParameterValues.DisableJSONCallback
        ]
        self.getImageUrls(methodParameters as [String:AnyObject]) { success, error in
            guard error == nil else {
                print("error")
                return
            }
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
