//
//  RecipeBoxApp.swift
//  RecipeBox
//
//  Created by Matt on 10/21/22.
//

import SwiftUI

@main
struct RecipeBoxApp: App {
    let persistenceController = PersistenceController.shared
    
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .onChange(of: scenePhase) { _ in
            // When the app is moved into the background, save changes
            persistenceController.save()
        }
    }
}
