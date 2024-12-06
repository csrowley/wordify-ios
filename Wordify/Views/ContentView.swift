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
    
    // Sample Data
    let cream = UIColor(red: 0.992, green: 0.984, blue: 0.831, alpha: 1)
    let silver = UIColor(red: 0.769, green: 0.769, blue: 0.769, alpha: 1)
    let jetBlack = UIColor(red:0.145, green: 0.145, blue: 0.145, alpha: 1)
    let seashell = UIColor(red: 1, green: 0.945, blue: 0.906, alpha: 1)
    let navyBlue = UIColor(red: 0, green: 0, blue: 0.502, alpha: 1)


    let gunmentalGray = UIColor(red:0.53, green: 0.62, blue: 0.67, alpha: 1)
    
    
    let words = [
        Word(
            word: "Aberrant",
            audio: "audio_aberrant.mp3",
            phonetic: "/ˈæb.ər.ənt/",
            definition: "Departing from an accepted standard.",
            category: "C2",
            wordType: "adjective",
            example: "His aberrant behavior surprised everyone at the meeting.",
            parentCategory: Category(category: "C2")
        ),

        Word(
            word: "Ebullient",
            audio: "audio_ebullient.mp3",
            phonetic: "/ɪˈbʌl.i.ənt/",
            definition: "Overflowing with enthusiasm or excitement.",
            category: "C1",
            wordType: "adjective",
            example: "Her ebullient personality made her the life of the party.",
            parentCategory: Category(category: "C1")

        )
    ]
    
    let tempCategories = [
        Category(category: "C2"),
        Category(category: "C1")
    ]
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color(seashell))
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        NavigationStack {
            
            TabView{
                UICollectionViewWrapper(selectedCategory: $selectedCategory)
                    .background(Color(seashell))
                    .edgesIgnoringSafeArea(.all) // Make it full-screen
                    .tabItem{
                        Label("Discover", systemImage: "magnifyingglass")
                    }
                    .onAppear{
                        Task{
                            
                            if isFirstLoad {
                                let currentDate = Date()
                                let formatter = DateFormatter()
                                formatter.dateFormat = "yyyy-mm-dd"
                                
                                lastLoginDate = formatter.string(from: currentDate)
                                if let myJsonData = viewModel.loadJSON(from: "word_data"){
                                    
                                    // Add modularity, where I can add new word sets when needed
                                    try await viewModel.importWordData(from: myJsonData, context: modelContext, categoryType: "C2")

                                }
                                
                                if let newJson = viewModel.loadJSON(from: "testData"){
                                    
                                    // Add modularity, where I can add new word sets when needed
                                    try await viewModel.importWordData(from: newJson, context: modelContext, categoryType: "C1")

                                }
                                isFirstLoad = false
                            }
                            else{
                                let daysSinceLogin = viewModel.checkForStreakUpdate(lastLoginDateStr: lastLoginDate)
                                
                                switch daysSinceLogin {
                                case 0:
                                    break
                                case 1:
                                    streakCount += 1
                                    break
                                default:
                                    streakCount = 0
                                    break
                                    //change to non lit flame
                                }
                                
                            }
                        }
                    }
                
                
                SavedWordsView() //insert ui Button
                    .tabItem{
                        Label("Saved", systemImage: "bookmark")
                    }
                
                Text("Hello:")
                    .tabItem{
                        Label("Quiz", systemImage: "graduationcap")
                    }
                
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Wordify") // Set your title here
                        .font(Font.custom("NewsreaderRoman-SemiBold", size: 40))
                        .foregroundStyle(Color(jetBlack))
                }
                
                ToolbarItem(placement: .topBarLeading){
                    NavigationLink{
                        AccountView()
                    } label: {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width:30, height:30)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(Color(navyBlue))
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing){
                    HStack{
                        Group{
                            if streakCount == 0{
                                Group {
                                    Image(systemName: "flame")
                                        .resizable()
                                    
                                    
                                    Text("\(streakCount)")
                                        .font(.custom("NewsReader16pt-Regular", size: 16))
                                }
                                .foregroundStyle(Color(navyBlue))
                            }
                            else{
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

// UICollectionView Wrapper
struct UICollectionViewWrapper: UIViewControllerRepresentable {
    @Environment(\.modelContext) var modelContext
    @AppStorage("lastScrollIndex") var lastScrollIndex: Int = 0
//    var words: [Word]
    @Binding var selectedCategory: Category?
    @Query var categories: [Category]
    
    let previewWords = [
        Word(
            word: "Aberrant",
            audio: "audio_aberrant.mp3",
            phonetic: "/ˈæb.ər.ənt/",
            definition: "Departing from an accepted standard.",
            category: "C2",
            wordType: "adjective",
            example: "His aberrant behavior surprised everyone at the meeting.",
            parentCategory: Category(category: "C2")
        )
    ]
    
    
    
    
    private var words: [Word] {
        if let category = selectedCategory {
            return category.word_list
        } else {
            
            return categories.first?.word_list ?? previewWords
        }
    }

        
    func makeUIViewController(context: Context) -> UICollectionViewController {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        layout.minimumLineSpacing = 0
        
        let collectionViewController = UICollectionViewController(collectionViewLayout: layout)
        collectionViewController.collectionView.isPagingEnabled = true
        collectionViewController.collectionView.showsVerticalScrollIndicator = false
        collectionViewController.collectionView.backgroundColor = .clear
        
        // Register custom cell
        collectionViewController.collectionView.register(WordCell.self, forCellWithReuseIdentifier: "WordCell")
        
        collectionViewController.collectionView.dataSource = context.coordinator
        collectionViewController.collectionView.delegate = context.coordinator
        
        collectionViewController.collectionView.bounces = false
        collectionViewController.collectionView.alwaysBounceVertical = false
        
        if !words.isEmpty {
            if lastScrollIndex >= words.count {
                lastScrollIndex = words.count
            }
        }
        
        if lastScrollIndex > 0{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                collectionViewController.collectionView.scrollToItem(
                    at: IndexPath(item: min(lastScrollIndex, words.count - 1), section: 0),
                    at: .top,
                    animated: false
                )
            }
        }
        else {
            lastScrollIndex = 0
        }
        
        return collectionViewController
    }
    
    func updateUIViewController(_ uiViewController: UICollectionViewController, context: Context) {
        // Update data if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, words: words)
    }
    
    class Coordinator: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
        var parent: UICollectionViewWrapper
        var words: [Word]
        var modelContext: ModelContext { parent.modelContext }
        
        init(parent: UICollectionViewWrapper, words: [Word]) {
            self.parent = parent
            self.words = words
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return words.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WordCell", for: indexPath) as! WordCell
            
            guard indexPath.item < parent.words.count else {
                return cell
            }
            
            let word = parent.words[indexPath.item]
            
            // Check if the word is already a favorite
            let tempCategories = [
                Category(category: "C1"),
                Category(category: "C2"),
                Category(category: "C3")

            ]
            
            cell.configure(with: word)
            cell.configureCategoryButton(with: parent.categories.isEmpty ? tempCategories : parent.categories)
            
            cell.onSaveTapped =  { [weak self] in
                word.isFavorite.toggle()
                do {
                    try? self?.modelContext.save()
                    cell.configure(with: word)
                    
                } catch {
                    print("error saving favorite: \(error.localizedDescription)")
                }
            }
            
            cell.onCategorySelected = { [weak self] category in
                self?.parent.selectedCategory = category
                
                collectionView.reloadData()
            }
            
            
            return cell
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            let page = Int(scrollView.contentOffset.y / scrollView.bounds.height)
            parent.lastScrollIndex = page
        }
        
    }
    
}



#Preview {
    ContentView()
}
