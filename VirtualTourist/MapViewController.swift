//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by jay raval on 10/30/18.
//  Copyright © 2018 jay raval. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController,MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!


    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tap.delegate = self as? UIGestureRecognizerDelegate
        mapView.addGestureRecognizer(tap)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func handleTap(_ sender:UITapGestureRecognizer) {
        let tappedLocation = sender.location(in: self.mapView)
        let tappedLocationCoordinate = mapView.convert(tappedLocation, toCoordinateFrom: mapView)
        let tappedPointAnnotation = MKPointAnnotation()
        tappedPointAnnotation.coordinate = tappedLocationCoordinate
        mapView.addAnnotation(tappedPointAnnotation)
    }
}

/// MapView annotation methods
extension MapViewController {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.performSegue(withIdentifier: "segueToPinImages", sender: self)
    }
}
