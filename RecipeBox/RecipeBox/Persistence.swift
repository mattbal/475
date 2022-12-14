import CoreData

struct PersistenceController {
    // A singleton for our entire app to use
    static let shared = PersistenceController()
    
    // Storage for Core Data
    let container: NSPersistentContainer
    
    // A test configuration so we can use CoreData in our SwiftUI previews 
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        
        // Create 10 example Recipes
        for _ in 0..<10 {
            let r = Recipe(context: controller.container.viewContext)
            r.id = UUID()
            r.title = "Spaghetti Carbonara"
            r.ingredients = ["1 lb of Spaghetti", "1/2 lb of bacon", "2 cloves of garlic", "1/4 cup of grated parmesan cheese", "2 eggs", "Fresh parsley"]
            r.steps = ["Fill a pot of water and set it over high heat. Heat a medium pan over medium heat", "When the pan is hot, add bacon", "Cook bacon until crispy, about 5 minutes", "When the water starts to boil add the pasta. Cook for 2 minutes less than the manufacturer's recommended time", "Drain the pasta", "Add the garlic to the pan. Stir for 30 seconds", "Add the strained pasta to the pan. Cook for 2 minutes, stirring ocassionally", "While pasta is cooking, whisk the 2 eggs and parmesan cheese together. Add freshly cracked black peper and salt to taste", "Take the pan off the heat and mix in the egg mixture", "Top with fresh parsley and serve"]
        }
        
        return controller
    }()
    
    // An initializer to load Core Data
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "RecipeBox")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // In the future, replace the fatal error with something else.
                // fatalError is okay for development, but shouldn't be used in production
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
