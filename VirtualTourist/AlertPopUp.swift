//
//  AlertPopUp.swift
//  VirtualTourist
//
//  Created by jay raval on 12/23/18.
//  Copyright © 2018 jay raval. All rights reserved.
//

import UIKit

extension UIViewController{
    func displayAlert(_ title:String,_ message:String){

        let alertController=UIAlertController(title:title, message:message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

}
