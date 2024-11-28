//
//  ContentView.swift
//  Wordify
//
//  Created by Chris Rowley on 11/27/24.
//

import SwiftUI
import UIKit

// Data Model
struct VocabularyWord: Identifiable {
    let id = UUID()
    let word: String
    let definition: String
}

// SwiftUI View
struct ContentView: View {
    // Sample Data
    let words = [
        VocabularyWord(word: "Aberration", definition: "A departure from what is normal or expected."),
        VocabularyWord(word: "Ascertain", definition: "To find out with certainty."),
        VocabularyWord(word: "Ebullient", definition: "Full of energy and enthusiasm.")
    ]
    
    var body: some View {

        
        TabView{
            
            UICollectionViewWrapper(words: words)
                .edgesIgnoringSafeArea(.all) // Make it full-screen
                .tabItem{
                    Label("Home", systemImage: "house")
                }
            
            Text("Hello:")
                .tabItem{
                    Label("Saved", systemImage: "bookmark")
                }
            Text("Hello:")
                .tabItem{
                    Label("Quiz", systemImage: "pencil")
                }
            Text("Hello:")
                .tabItem{
                    Label("Collections", systemImage: "shippingbox")
                }
        }
    }
}

// UICollectionView Wrapper
struct UICollectionViewWrapper: UIViewControllerRepresentable {
    var words: [VocabularyWord]

    func makeUIViewController(context: Context) -> UICollectionViewController {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        layout.minimumLineSpacing = 0 // No spacing between pages
        
        let collectionViewController = UICollectionViewController(collectionViewLayout: layout)
        collectionViewController.collectionView.isPagingEnabled = true
        collectionViewController.collectionView.showsVerticalScrollIndicator = false
        collectionViewController.collectionView.backgroundColor = .clear
        
        // Register custom cell
        collectionViewController.collectionView.register(WordCell.self, forCellWithReuseIdentifier: "WordCell")
        
        collectionViewController.collectionView.dataSource = context.coordinator
        return collectionViewController
    }

    func updateUIViewController(_ uiViewController: UICollectionViewController, context: Context) {
        // Update data if needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UICollectionViewDataSource {
        var parent: UICollectionViewWrapper

        init(_ parent: UICollectionViewWrapper) {
            self.parent = parent
        }

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return parent.words.count
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WordCell", for: indexPath) as! WordCell
            let word = parent.words[indexPath.item]
            cell.configure(with: word)
            return cell
        }
    }
}

// Custom UICollectionView Cell
class WordCell: UICollectionViewCell {
    private let wordLabel = UILabel()
    private let definitionLabel = UILabel()
    
    private let saveButton = UIButton(type: .system)
    
    var onSaveTapped:  (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        wordLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        wordLabel.textColor = .black
        wordLabel.textAlignment = .center

        definitionLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        definitionLabel.textColor = .gray
        definitionLabel.textAlignment = .center
        definitionLabel.numberOfLines = 0

        
        saveButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
        saveButton.tintColor = .black
        
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        saveButton.contentMode = .scaleAspectFit
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [wordLabel, definitionLabel])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center

        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with word: VocabularyWord) {
        wordLabel.text = word.word
        definitionLabel.text = word.definition
    }
    
    @objc private func saveButtonTapped() {
        onSaveTapped?()
    }
}


#Preview {
    ContentView()
}
