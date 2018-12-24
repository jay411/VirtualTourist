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
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
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
                fatalError("could not delete data")
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
            self.getImages(pinLatitude!, pinLongitude!)
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
        self.newCollectionButton.isEnabled = false
        self.newCollectionButton.titleLabel?.text = "Loading New Collection....."
        self.loadingIndicator.startAnimating()
        self.loadingIndicator.isHidden = false
        FlickrClient.sharedInstance().getImagesForPoint(pinLatitude, pinLongitude) { (success, photos, error) in
            guard error == nil else {
                fatalError("no images found")
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
                            fatalError("Could not save")
                        }
                }
                performUIUpdatesOnMain {
                    print("performing fetch")
                    self.performFetch()
                    self.photoCollectionView.reloadData()
                    self.loadingIndicator.stopAnimating()
                    self.loadingIndicator.isHidden = true
                    self.newCollectionButton.titleLabel?.text = "New Collection"
                    self.newCollectionButton.isEnabled = true
                }
            }
        }


    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// Mark: collection view methods
extension PhotoCellsViewController {

     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[0].numberOfObjects ?? 20
    }

     func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 3
    }
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let aCell = fetchedResultsController.object(at: indexPath)

        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell

        if let photoData = aCell.photos{
            print("photo data found")
            cell.cellImage?.image = UIImage(data:photoData)
        }
        else {
            cell.cellImage?.image = self.image
        }
        return cell
    }
}

// Mark: network calls to get photos
extension PhotoViewController {


}
