//
//  DataController.swift
//  VirtualTourist
//
//  Created by Grzegorz Bielanski on 23/12/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation
import CoreData

class DataController {
  let persistanceContainer: NSPersistentContainer

  var viewContext: NSManagedObjectContext {
    return persistanceContainer.viewContext
  }

  var backgroundContext: NSManagedObjectContext!

  init(modelName: String) {
    persistanceContainer = NSPersistentContainer(name: modelName)
  }

  func configureContexts(){
    backgroundContext = persistanceContainer.newBackgroundContext()

    viewContext.automaticallyMergesChangesFromParent = true
    backgroundContext.automaticallyMergesChangesFromParent = true

    backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

    viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
  }

  func load(completion: (() -> Void)? = nil){
    persistanceContainer.loadPersistentStores{ (storeDescription, error) in
      guard error == nil else {
        fatalError(error!.localizedDescription)
      }

      self.configureContexts()
      completion?()
    }
  }
}

