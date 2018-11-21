//
//  GCDBlackBox.swift
//  VirtualTourist
//
//  Created by jay raval on 11/14/18.
//  Copyright © 2018 jay raval. All rights reserved.
//


import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
