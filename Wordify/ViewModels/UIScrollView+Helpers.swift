//
//  UIScrollView+Helpers.swift
//  Wordify
//
//  Created by Chris Rowley on 12/6/24.
//

import UIKit
import SwiftData
import SwiftUI

// UICollectionView Wrapper
struct UICollectionViewWrapper: UIViewControllerRepresentable {
    @Environment(\.modelContext) var modelContext
    @AppStorage("lastScrollIndex") var lastScrollIndex: Int = 0
//    var words: [Word]
    @Binding var selectedCategory: Category?
    @Query var categories: [Category]
    @Query var allWords: [Word]
    
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
            return allWords.isEmpty ? previewWords : allWords
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
                lastScrollIndex = words.count - 1  // Changed to count - 1
            }
        }

        if lastScrollIndex > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                collectionViewController.collectionView.scrollToItem(
                    at: IndexPath(item: min(lastScrollIndex, words.count - 1), section: 0),  // Changed to count - 1
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
                self?.parent.lastScrollIndex = 0
                
                
                collectionView.reloadData()
                collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)

            }
            
            
            return cell
        }
        
        
        func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            let itemHeight = UIScreen.main.bounds.height
            
            let proposedIndex = Int(targetContentOffset.pointee.y / itemHeight)
            
            let boundedIndex = max(0, min(proposedIndex, words.count - 1)) // or words.count
            
            targetContentOffset.pointee.y = CGFloat(boundedIndex) * itemHeight
            
            parent.lastScrollIndex = boundedIndex
        }
        
    }
    
}
