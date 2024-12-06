//
//  WordifyApp.swift
//  Wordify
//
//  Created by Chris Rowley on 11/27/24.
//

import SwiftUI
import SwiftData

@main
struct WordifyApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Word.self,
            Favorite.self,
            Category.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
