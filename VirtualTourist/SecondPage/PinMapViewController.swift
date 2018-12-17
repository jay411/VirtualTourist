//
//  PinMapViewController.swift
//  VirtualTourist
//
//  Created by jay raval on 12/13/18.
//  Copyright © 2018 jay raval. All rights reserved.
//

import UIKit
import MapKit
class PinMapViewController: UIViewController,MKMapViewDelegate {

    @IBOutlet weak var pinMapView: MKMapView!
    var initialMapData: [String:CLLocationDegrees]?
    var pinAnnotation: MKPointAnnotation?



    fileprivate func setSpan() {
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        if let pin = pinAnnotation{
            let region = MKCoordinateRegion(center: pin.coordinate, span: span)
            self.pinMapView.setRegion(region, animated: true)
        }

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        pinMapView.delegate = self
        self.setSpan()
        

        // Do any additional setup after loading the view.
    }

    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        if let pin = pinAnnotation {
            self.pinMapView.addAnnotation(pin)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


