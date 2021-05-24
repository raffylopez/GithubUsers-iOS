//
//  Copyright © 2021 Raf. All rights reserved.
//

import Foundation
import CoreData

class CoreDataService {
    
    public static let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    public static let shared = CoreDataService()
    
    static var persistentContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: getConfig().xcPersisentContainerName )
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
    }()
    
    let context = persistentContainer.viewContext
    
    public func saveContext() throws {
        if context.hasChanges {
            try context.save()
        }
    }
}
