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
    var initialMapData: [String:CLLocationDegrees]?

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tap.delegate = self as? UIGestureRecognizerDelegate
        mapView.addGestureRecognizer(tap)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initialMapData = UserDefaults.standard.value(forKey: "locationData") as? [String : CLLocationDegrees]
         if let mapData = initialMapData, mapData != nil {
            let spanLat = mapData["spanLat"]
            let spanLon = mapData["spanLon"]
            let span = MKCoordinateSpan(latitudeDelta: spanLat!, longitudeDelta: spanLon!)

            let centerLat = mapData["centerLat"]
            let centerLon = mapData["centerLon"]
            let newCenter = CLLocationCoordinate2DMake(centerLat!, centerLon!)
            let newRegion = MKCoordinateRegion(center: newCenter, span: span)
            let newLocation = CLLocation(latitude: centerLat!, longitude: centerLon!)
            mapView.setRegion(newRegion, animated: false)
        }

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

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        initialMapData = ["spanLat":mapView.region.span.latitudeDelta, "spanLon":mapView.region.span.longitudeDelta, "centerLat":mapView.centerCoordinate.latitude, "centerLon":mapView.centerCoordinate.longitude]
        UserDefaults.standard.set(initialMapData, forKey: "locationData")
        UserDefaults.standard.synchronize()
    }
}
