import CoreData

final class DataBaseStore {
    
    // MARK: - Public properties
    static let shared = DataBaseStore()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(
            name: "Tracker"
        )
        container.loadPersistentStores(completionHandler: {
            (
                storeDescription,
                error
            ) in
            if let error = error as NSError? {
                fatalError(
                    "Unresolved error \(error), \(error.userInfo)"
                )
            }
        })
        return container
    }()
    
    // MARK: - Public methods
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print(
                    "Unresolved error \(nserror), \(nserror.userInfo)"
                )
            }
        }
    }
    
    func deleteAll(from entity: String) {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity)

        do {
            let objects = try context.fetch(fetchRequest)
            for object in objects {
                context.delete(object)
            }
            
            saveContext ()
            print("Все объекты успешно удалены.")
        } catch {
            print("Ошибка при удалении объектов: \(error)")
        }
    }
    
    private init() {}
}
