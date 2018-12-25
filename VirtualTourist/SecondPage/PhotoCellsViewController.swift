//
//  PhotoCellsViewController.swift
//  VirtualTourist
//
//  Created by jay raval on 11/12/18.
//  Copyright © 2018 jay raval. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class PhotoCellsViewController: UIViewController,NSFetchedResultsControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate{

    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    var dataController:DataController!
    var pinLatitude:CLLocationDegrees?
    var pinLongitude:CLLocationDegrees?
    var image = UIImage(named: "sample")
    var iData: Data?
    var selectedPin:Pin!
    var photoDataArray:[Data]?


    
    @IBAction func newCollection(_ sender: Any) {
        if let fetchedObjects = fetchedResultsController.fetchedObjects {
            if fetchedObjects.count != 0 {
                for item in fetchedObjects {
                    dataController.viewContext.delete(item)
                }
            }
            do {
                try dataController.viewContext.save()
            }
            catch{
                self.displayAlert("Database error", "Error deleting existing data")
            }
        }
        self.getImages(pinLatitude!, pinLongitude!)
        performUIUpdatesOnMain {
            self.photoCollectionView.reloadData()

        }
    }

    var fetchedResultsController:NSFetchedResultsController<PinPhotos>!

    fileprivate func setupFetchResultsController() {
        let fetchRequest:NSFetchRequest<PinPhotos> = PinPhotos.fetchRequest()

        let sortDescriptor = NSSortDescriptor(key: "photos", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let predicate = NSPredicate(format: "pin == %@", self.selectedPin)
        fetchRequest.predicate = predicate
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchedResultsController.performFetch()
        } catch  {
            print("could not fetch")
        }
    }

    fileprivate func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch  {
            print("could not fetch")
        }
        print(fetchedResultsController.fetchedObjects!.count)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupFetchResultsController()
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        if fetchedResultsController.fetchedObjects!.count == 0 {
            print("fetch results count (photos):",fetchedResultsController.fetchedObjects!.count)
            DispatchQueue.global(qos: .userInitiated).async {
                self.getImages(self.pinLatitude!, self.pinLongitude!)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("view will appear called")
        super.viewWillAppear(animated)
        setupFetchResultsController()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }

    func getImages(_ pinLatitude:CLLocationDegrees,_ pinLongitude:CLLocationDegrees) {
        print("get images called")
        performUIUpdatesOnMain {
            self.newCollectionButton.isEnabled = false
            self.newCollectionButton.setTitle("Loading New Collection.....", for: .normal)
        }

        FlickrClient.sharedInstance().getImagesForPoint(pinLatitude, pinLongitude) { (success, photos, error) in
            guard error == nil else {
                self.displayAlert("Photos Error", "\(String(describing: error!.localizedDescription))")
                return
            }
    
            if let photosArray = photos {
                self.photoDataArray = photosArray
                for item in photosArray {
                    let photo = PinPhotos(context: self.dataController.viewContext)
                    photo.photos = item
                    photo.pin = self.selectedPin
                        do {
                            try self.dataController.viewContext.save()
                        }
                        catch {
                            self.displayAlert("Database Error", "Could not save")
                        }
                }
                performUIUpdatesOnMain {
                    print("performing fetch")
                    self.performFetch()
                    self.photoCollectionView.reloadData()
                    self.newCollectionButton.setTitle("New Collection", for: .normal)
                    self.newCollectionButton.isEnabled = true
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// Mark: collection view methods
extension PhotoCellsViewController:UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = UIScreen.main.bounds.width
        let scale = (width / 3) - 6

        return CGSize(width: scale, height: scale)
    }

     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Collection View methods objects",fetchedResultsController.sections?[0].numberOfObjects ?? 20)
        if fetchedResultsController.sections?[0].numberOfObjects == 0 {
            return 12
        }
        return fetchedResultsController.sections?[0].numberOfObjects ?? 20
    }

     func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 3
    }

     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        if fetchedResultsController.fetchedObjects!.count != 0 {
            let aCell = fetchedResultsController.object(at: indexPath)
            
            if let photoData = aCell.photos{
                print("photo data found")
                cell.cellImage?.image = UIImage(data:photoData)

            }
            else {
                cell.cellImage?.image = self.image
            }
        }
        else {
            cell.cellImage?.image = self.image
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(photoToDelete)
        do {
            try dataController.viewContext.save()
        } catch  {
            self.displayAlert("Database Error", "Could not delete photo")
        }
    }
}

// Mark: cell updates
extension PhotoCellsViewController {

}
