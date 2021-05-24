//
//  Created by Volare on 2/28/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import Foundation
import CoreData

class CoreDataService {
    
    public static let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    public static let shared = CoreDataService()
    
    internal static let persistentContainerName = getConfig().xcPersisentContainerName
    
    internal static var persistentContainer: NSPersistentContainer {
        get {
        let container = NSPersistentContainer(name: Self.persistentContainerName )
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
        }
    }
    
    let context = persistentContainer.viewContext
    
    public func saveContext() throws {
        if context.hasChanges {
            try context.save()
        }
    }
}
