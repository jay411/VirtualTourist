//
//  PhotoViewController.swift
//  VirtualTourist
//
//  Created by jay raval on 11/11/18.
//  Copyright © 2018 jay raval. All rights reserved.
//

import UIKit
import Alamofire
import MapKit
import CoreData

class PhotoViewController: UIViewController {

    var dataController:DataController!
    var pinRecived: MKPointAnnotation?
    var selectedPin:Pin!


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        if segue.destination is PinMapViewController {
            let destinationViewController = segue.destination as! PinMapViewController
            if let pin = self.pinRecived {
                print("transferringPin")
                destinationViewController.pinAnnotation = pin
                destinationViewController.pinAnnotation?.title = self.selectedPin.address
            }
        }
        if segue.destination is PhotoCellsViewController {
            let destinationViewController = segue.destination as! PhotoCellsViewController
            destinationViewController.dataController = self.dataController
            if let pin = self.pinRecived {
                print("transferringPin")
                destinationViewController.pinLatitude = pin.coordinate.latitude
                destinationViewController.pinLongitude = pin.coordinate.longitude
                destinationViewController.selectedPin = self.selectedPin
            }
        }
    }


}
