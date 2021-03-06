//
//  DataController.swift
//  VirtualTourist
//
//  Created by jay raval on 12/6/18.
//  Copyright © 2018 jay raval. All rights reserved.
//


import Foundation
import CoreData

class DataController {

    let persistentContainer:NSPersistentContainer

    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }


    init(modelName:String) {
        persistentContainer = NSPersistentContainer(name: modelName)

    }

    func configureContexts() {
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }

    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
            self.configureContexts()
            completion?()
        }
    }
}

// MARK: - Autosaving

extension DataController {
    func autoSaveViewContext(interval:TimeInterval = 30) {
        print("autosaving")

        guard interval > 0 else {
            print("cannot set negative autosave interval")
            return
        }

        if viewContext.hasChanges {
            try? viewContext.save()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
}
