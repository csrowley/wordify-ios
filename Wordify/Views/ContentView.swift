//
//  ContentView.swift
//  Wordify
//
//  Created by Chris Rowley on 11/27/24.
//

import SwiftUI
import UIKit
import SwiftData
import AVFoundation

// Data Model
struct VocabularyWord: Identifiable {
    let id = UUID()
    let word: String
    let definition: String
}

// SwiftUI View
struct ContentView: View {
    @AppStorage("isFirstLoad") var isFirstLoad = true
    @AppStorage("streakCount") var streakCount = 0
    @AppStorage("lastScrollIndex") var lastScrollIndex: Int = 0
    @AppStorage("lastLoginDate") var lastLoginDate = ""
    @Environment(\.modelContext) var modelContext
    @Query var wordData: [Word]
    @Query var categories: [Category]
    @State private var selectedCategory: Category?
    
    @State private var viewModel = ViewModel()
    @State private var favoritingUpdator: WordFavoritingProtocol?
    @State private var showAccountView = false
    @State private var isLoading = true // Add this
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .seashell
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        Group {
            if isLoading {
                VStack {
                    ProgressView()
                    Text("Loading Words...")
                        .font(Font.custom("NewsreaderRoman-SemiBold", size: 20))
                }
            } else {
                NavigationStack {
                    TabView {
                        UICollectionViewWrapper(selectedCategory: $selectedCategory)
                            .background(Color(.seashell))
                            .edgesIgnoringSafeArea(.all)
                            .tabItem {
                                Label("Discover", systemImage: "magnifyingglass")
                            }
                        
                        QuizView()
                            .tabItem {
                                Label("Quiz", systemImage: "graduationcap")
                            }
                        
                        SavedWordsView()
                            .tabItem {
                                Label("Saved", systemImage: "bookmark")
                            }
                    }
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("Wordify")
                                .font(Font.custom("NewsreaderRoman-SemiBold", size: 40))
                                .foregroundStyle(Color(.jetBlack))
                        }
                        
                        ToolbarItem(placement: .topBarLeading) {
                            NavigationLink {
                                AccountView()
                            } label: {
                                Image(systemName: "person.crop.circle")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(Color(.navyBlue))
                            }
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            HStack {
                                Group {
                                    if streakCount == 0 {
                                        Group {
                                            Image(systemName: "flame")
                                                .resizable()
                                            Text("\(streakCount)")
                                                .font(.custom("NewsReader16pt-Regular", size: 16))
                                        }
                                        .foregroundStyle(Color(.navyBlue))
                                    } else {
                                        Group {
                                            Image(systemName: "flame.fill")
                                                .resizable()
                                            Text("\(streakCount)")
                                                .font(.custom("NewsReader16pt-Regular", size: 16))
                                        }
                                        .foregroundStyle(.orange)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .task {
            await loadInitialData()
        }
    }
    
    private func loadInitialData() async {
        if isFirstLoad {
            let currentDate = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-mm-dd"
            lastLoginDate = formatter.string(from: currentDate)
            
            if let myJsonData = viewModel.loadJSON(from: "word_data") {
                try? await viewModel.importWordData(from: myJsonData, context: modelContext, categoryType: "C2")
            }
            
            if let newJson = viewModel.loadJSON(from: "testData") {
                try? await viewModel.importWordData(from: newJson, context: modelContext, categoryType: "C1")
            }
            
            isFirstLoad = false
        } else {
            let daysSinceLogin = viewModel.checkForStreakUpdate(lastLoginDateStr: lastLoginDate)
            switch daysSinceLogin {
            case 0: break
            case 1: streakCount += 1
            default: streakCount = 0
            }
        }
        
        // Ensure SwiftData is ready
        try? await Task.sleep(nanoseconds: 500_000_000)
        isLoading = false
    }
}



#Preview {
    ContentView()
}
