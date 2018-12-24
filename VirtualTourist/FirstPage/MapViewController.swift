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
import CoreData

class MapViewController: UIViewController,MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var initialMapData: [String:CLLocationDegrees]?

    var dataController:DataController!
    var mapPins: [Pin]?
    var pinAnnotation = MKPointAnnotation()
    var selectedPin: MKAnnotation?
    var tappedPin:Pin?




    private func fetchPins() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
            if let result = try? dataController.viewContext.fetch(fetchRequest) {
                print("pins found",result.count)
                mapPins = result
                print(mapPins?.count)
            }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tap.minimumPressDuration = 0.5
        tap.numberOfTouchesRequired = 1
        tap.delegate = self as? UIGestureRecognizerDelegate
        mapView.addGestureRecognizer(tap)
        self.fetchPins()
        // Do any additional setup after loading the view, typically from a nib.
    }
    fileprivate func setSpan() {
        initialMapData = UserDefaults.standard.value(forKey: "locationData") as? [String : CLLocationDegrees]

        if let mapData = initialMapData {
            let spanLat = mapData["spanLat"]
            let spanLon = mapData["spanLon"]
            let span = MKCoordinateSpan(latitudeDelta: spanLat!, longitudeDelta: spanLon!)

            let centerLat = mapData["centerLat"]
            let centerLon = mapData["centerLon"]
            let newCenter = CLLocationCoordinate2DMake(centerLat!, centerLon!)
            let newRegion = MKCoordinateRegion(center: newCenter, span: span)
            mapView.setRegion(newRegion, animated: false)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setSpan()
        self.showAllPins(mapPins)

        }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func handleTap(_ sender:UILongPressGestureRecognizer) {
        let tappedLocation = sender.location(in: self.mapView)
        let tappedLocationCoordinate = mapView.convert(tappedLocation, toCoordinateFrom: mapView)
        let tappedPointAnnotation = MKPointAnnotation()
        tappedPointAnnotation.coordinate = tappedLocationCoordinate
        findAddress(tappedPointAnnotation.coordinate) { (addressString) in
            if let addressTitle = addressString {
                print(addressTitle)
                tappedPointAnnotation.title = addressTitle
            }
            else {
                print("address nil")
                tappedPointAnnotation.title = "annotation"
            }
        }
        if sender.state.rawValue == 3 {
        self.addPin(pointAnnotation: tappedPointAnnotation)
        }
    }
}

/// MapView annotation methods
extension MapViewController {


    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let pointAnnotation = view.annotation {
            print("view annotation selected")
            pinAnnotation.coordinate = pointAnnotation.coordinate
            self.findTappedPin(self.pinAnnotation)
            mapView.deselectAnnotation(pointAnnotation, animated: true)
            }
        print(self.tappedPin == nil)
        self.performSegue(withIdentifier: "segueToPinImages", sender: self)

    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let _ = tappedPin {
            if segue.identifier == "segueToPinImages" {
                print("seguing to collection")
                let destination = segue.destination as! PhotoViewController
                destination.dataController = self.dataController
                destination.pinRecived = pinAnnotation
                destination.selectedPin = self.tappedPin
            }
        }
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        initialMapData = ["spanLat":mapView.region.span.latitudeDelta, "spanLon":mapView.region.span.longitudeDelta, "centerLat":mapView.centerCoordinate.latitude, "centerLon":mapView.centerCoordinate.longitude]
        UserDefaults.standard.set(initialMapData, forKey: "locationData")
        UserDefaults.standard.synchronize()
    }

      func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let pointAnnotation = view.annotation {
            print("view annotation selected")
            pinAnnotation.coordinate = pointAnnotation.coordinate
            self.findTappedPin(self.pinAnnotation)
            mapView.deselectAnnotation(pointAnnotation, animated: true)
        }
        print(self.tappedPin == nil)
        self.performSegue(withIdentifier: "segueToPinImages", sender: self)
    }
}

// Mark -- Pin  methods
extension MapViewController {

    func addPin(pointAnnotation:MKPointAnnotation) {
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = pointAnnotation.coordinate.latitude
        pin.longitude = pointAnnotation.coordinate.longitude
        pin.address = pointAnnotation.title
        do {
            try dataController.viewContext.save()
            print("pin saved")
        }
        catch {
            fatalError("Could not save")
        }
        mapView.addAnnotation(pointAnnotation)
    }

    func showAllPins(_ pins:[Pin]?){
        var annotations = [MKPointAnnotation]()
        if let pinArray = pins {

            for pin in pinArray {
            let pinAnnotation = MKPointAnnotation()

            pinAnnotation.coordinate.longitude = pin.longitude
            pinAnnotation.coordinate.latitude = pin.latitude
            pinAnnotation.title = pin.address
            annotations.append(pinAnnotation)
            self.mapView.addAnnotation(pinAnnotation)
        }
    }
}

    func findTappedPin(_ findPin:MKPointAnnotation?){
        // fetch all pins here as well
        self.fetchPins()
        if let pins = mapPins {
            for randomPin in pins {
                print(pins.count)
                print("looking for pins")
                if (randomPin.latitude == findPin?.coordinate.latitude && randomPin.longitude == findPin?.coordinate.longitude){
                    print("found pin",randomPin)
                    self.tappedPin = randomPin
                }
            }
        }
    }

}

extension MapViewController {
    func findAddress(_ coordinate:CLLocationCoordinate2D,_ completionHandler: @escaping (String?)->Void) {
        let geocoder = CLGeocoder()

        // Look up the location and pass it to the completion handler
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(location,
                                        completionHandler: { (placemarks, error) in
                                            if error == nil {
                                                let firstLocation = placemarks?[0].name
                                                print (firstLocation)
                                                completionHandler(firstLocation)
                                            }
                                            else {
                                                // An error occurred during geocoding.
                                                completionHandler(nil)
                                            }
        })
     }
}
