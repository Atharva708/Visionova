//
//  VisionovaApp.swift
//  Visionova
//
//  Created by Atharva Gour on 20/11/25.
//

import SwiftUI
import CoreData

@main
struct VisionovaApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
