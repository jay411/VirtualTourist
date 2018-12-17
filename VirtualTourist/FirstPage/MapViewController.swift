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

class MapViewController: UIViewController,MKMapViewDelegate,NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var initialMapData: [String:CLLocationDegrees]?

    var dataController:DataController!
    var fetchedResultsController:NSFetchedResultsController<Pin>!
    var mapPins: [Pin]?
    var pinAnnotation = MKPointAnnotation()
    var selectedPin: MKAnnotation?
    var tappedPin:Pin?

//    fileprivate func setupFetchedResultsController() {
//        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
//        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: true)
//        fetchRequest.sortDescriptors = [sortDescriptor]
//
//        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
//        fetchedResultsController.delegate = self
//
//        do {
//            try fetchedResultsController.performFetch()
//        } catch {
//            fatalError("error in fetching results: \(error.localizedDescription)")
//        }
//        if let _ = fetchedResultsController.fetchedObjects {
//            self.mapPins = fetchedResultsController.fetchedObjects
//        }
//
//    }
    private func fetchPins() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
            if let result = try? dataController.viewContext.fetch(fetchRequest) {
                print("pins found",result.count)
                mapPins = result
            }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tap.delegate = self as? UIGestureRecognizerDelegate
        mapView.addGestureRecognizer(tap)
        self.fetchPins()
//        self.setupFetchedResultsController()
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
//            let newLocation = CLLocation(latitude: centerLat!, longitude: centerLon!)
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

    @objc func handleTap(_ sender:UITapGestureRecognizer) {
        let tappedLocation = sender.location(in: self.mapView)
        let tappedLocationCoordinate = mapView.convert(tappedLocation, toCoordinateFrom: mapView)
        let tappedPointAnnotation = MKPointAnnotation()
        tappedPointAnnotation.coordinate = tappedLocationCoordinate
//        FlickrClient.sharedInstance().getImagesForPoint(tappedPointAnnotation.coordinate.latitude, tappedPointAnnotation.coordinate.longitude) { (success, error) in
//            guard error == nil else {
//                print("more error")
//                return
//            }
//        }
        self.addPin(pointAnnotation: tappedPointAnnotation)
    }
}

/// MapView annotation methods
extension MapViewController {


    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let pointAnnotation = view.annotation {
            print("view annotation selected")
            pinAnnotation.coordinate = pointAnnotation.coordinate
            self.findTappedPin(pinAnnotation)
        }

        self.performSegue(withIdentifier: "segueToPinImages", sender: self)

    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let _ = tappedPin {
        if segue.identifier == "segueToPinImages" {
            let destination = segue.destination as! PhotoViewController
            destination.dataController = self.dataController
            destination.pinRecived = pinAnnotation
            destination.selectedPin = tappedPin
            }
        }
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        initialMapData = ["spanLat":mapView.region.span.latitudeDelta, "spanLon":mapView.region.span.longitudeDelta, "centerLat":mapView.centerCoordinate.latitude, "centerLon":mapView.centerCoordinate.longitude]
        UserDefaults.standard.set(initialMapData, forKey: "locationData")
        UserDefaults.standard.synchronize()
    }
}

// Mark -- Pin  methods
extension MapViewController {

    func addPin(pointAnnotation:MKPointAnnotation) {
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = pointAnnotation.coordinate.latitude
        pin.longitude = pointAnnotation.coordinate.longitude
        do {
            try dataController.viewContext.save()
            print("pins saved")
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
            annotations.append(pinAnnotation)
            self.mapView.addAnnotation(pinAnnotation)
        }
        self.mapView.addAnnotations(annotations)
    }
}

    func findTappedPin(_ findPin:MKPointAnnotation?){
//        print(fetchedResultsController.fetchedObjects!)
        if let pins = mapPins {
            for randomPin in pins {
                if (randomPin.latitude == findPin?.coordinate.latitude && randomPin.longitude == findPin?.coordinate.longitude){
                    print("found pin",randomPin)
                    self.tappedPin = randomPin
                }
            }
        }
    }

}
