//
//  PhotoCellsViewController.swift
//  VirtualTourist
//
//  Created by jay raval on 11/12/18.
//  Copyright © 2018 jay raval. All rights reserved.
//

import UIKit

class PhotoCellsViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        var image = UIImage(named: "sample")
        // Do any additional setup after loading the view.
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
        let numberOfItems: Int = 200
        return numberOfItems
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) 
        cell.backgroundColor = UIColor.black
        return cell
    }
}
