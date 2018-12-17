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

class PhotoCellsViewController: UICollectionViewController,NSFetchedResultsControllerDelegate {

    var dataController:DataController!
    var pinLatitude:CLLocationDegrees?
    var pinLongitude:CLLocationDegrees?
    var image = UIImage(named: "sample")
    var selectedPin:Pin!
    
    var fetchedResultsController:NSFetchedResultsController<PinPhotos>!

    fileprivate func setupFetchResultsController() {
        let fetchRequest:NSFetchRequest<PinPhotos> = PinPhotos.fetchRequest()

        let sortDescriptor = NSSortDescriptor(key: "photos", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let predicate = NSPredicate(format: "pin == %@", selectedPin)
        fetchRequest.predicate = predicate
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchedResultsController.performFetch()
        } catch  {
            fatalError("could not perform fetch:\(error.localizedDescription)")
        }

        fetchedResultsController.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupFetchResultsController()
        print("fetched objects",fetchedResultsController.fetchedObjects!.count)
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

extension PhotoCellsViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numberOfItems: Int = 15
        return numberOfItems
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        cell.photoImage?.image = self.image
        return cell
    }
}