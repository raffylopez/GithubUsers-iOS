//
//  Copyright © 2021 Raf. All rights reserved.
//

import Foundation
import CoreData

/** CoreData stack, guarantees a singleton for its persistent container  */
class CoreDataService {
    
    public static let shared = CoreDataService()
    let context = persistentContainer.viewContext

    static var persistentContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: getConfig().xcPersisentContainerName )
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
    }()

    public func saveContext() throws {
        if context.hasChanges {
            try context.save()
        }
    }
}
