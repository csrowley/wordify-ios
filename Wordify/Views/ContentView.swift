//
//  ContentView.swift
//  Wordify
//
//  Created by Chris Rowley on 11/27/24.
//

import SwiftUI
import UIKit
import SwiftData

// Data Model
struct VocabularyWord: Identifiable {
    let id = UUID()
    let word: String
    let definition: String
}

// SwiftUI View
struct ContentView: View {
    @AppStorage("isFirstLoad") var isFirstLoad = true
    @Environment(\.modelContext) var modelContext
    @Query var wordData: [Word]
    @State private var viewModel = ViewModel()
    // Sample Data
    let cream = UIColor(red: 0.992, green: 0.984, blue: 0.831, alpha: 1)
    let silver = UIColor(red: 0.769, green: 0.769, blue: 0.769, alpha: 1)
    let jetBlack = UIColor(red:0.145, green: 0.145, blue: 0.145, alpha: 1)

    let gunmentalGray = UIColor(red:0.53, green: 0.62, blue: 0.67, alpha: 1)
    
    
    let words = [
        Word(
            word: "Aberrant",
            audio: "audio_aberrant.mp3",
            phonetic: "/ˈæb.ər.ənt/",
            definition: "Departing from an accepted standard.",
            difficultyLevel: "C2",
            wordType: "adjective",
            example: "His aberrant behavior surprised everyone at the meeting."
        ),

        Word(
            word: "Ascertain",
            audio: "audio_ascertain.mp3",
            phonetic: "/ˌæs.əˈteɪn/",
            definition: "To find out or learn with certainty.",
            difficultyLevel: "B2",
            wordType: "verb",
            example: "We need to ascertain the cause of the power outage."
        ),

        Word(
            word: "Ebullient",
            audio: "audio_ebullient.mp3",
            phonetic: "/ɪˈbʌl.i.ənt/",
            definition: "Overflowing with enthusiasm or excitement.",
            difficultyLevel: "C1",
            wordType: "adjective",
            example: "Her ebullient personality made her the life of the party."
        )
    ]
    
    var body: some View {
        NavigationStack {
            TabView{
                UICollectionViewWrapper(words: wordData.isEmpty ? words : wordData)
                    .background(Color(silver))
                    .edgesIgnoringSafeArea(.all) // Make it full-screen
                    .tabItem{
                        Label("Home", systemImage: "house")
                    }
                    .onAppear{
                        Task{
                            if isFirstLoad {
                                if let myJsonData = viewModel.loadGreJSON(){
                                    try await viewModel.importWordData(from: myJsonData, context: modelContext)
                                }
                                isFirstLoad = false
                            }
                        }
                    }
                
                
                SavedWordsView()
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
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Wordify") // Set your title here
                        .font(.largeTitle)
                        .bold()
                }
            }
        }
        
        
    }
    
}

// UICollectionView Wrapper
struct UICollectionViewWrapper: UIViewControllerRepresentable {
    
    
    var words: [Word]

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
    
    let jetBlack = UIColor(red:0.145, green: 0.145, blue: 0.145, alpha: 1)

    
    private let wordLabel = UILabel()
    private let definitionLabel = UILabel()
    private let phoneticsLabel = UILabel()
    
    private let saveButton = UIButton(type: .system)
    private let soundButton = UIButton(type: .system)
    
    var onSaveTapped:  (() -> Void)?
    var onSoundTapped:  (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        wordLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        wordLabel.textColor = jetBlack
        wordLabel.textAlignment = .center

        definitionLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        definitionLabel.textColor = .gray
        definitionLabel.textAlignment = .center
        definitionLabel.numberOfLines = 0
        
        phoneticsLabel.font = UIFont.italicSystemFont(ofSize: 18)
        phoneticsLabel.textColor = .black
        phoneticsLabel.textAlignment = .center
        phoneticsLabel.numberOfLines = 0


        
        saveButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
        saveButton.tintColor = .black
        
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        saveButton.contentMode = .scaleAspectFit
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        soundButton.setImage(UIImage(systemName: "speaker.wave.2"), for: .normal)
        soundButton.tintColor = .black
        soundButton.addTarget(self, action: #selector(soundButtonTapped), for: .touchUpInside)
        soundButton.contentMode = .scaleAspectFit
        soundButton.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonStackView = UIStackView(arrangedSubviews: [saveButton, soundButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 25
        buttonStackView.alignment = .center
        
        let mainStackView = UIStackView(arrangedSubviews: [wordLabel, phoneticsLabel, definitionLabel, buttonStackView])
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        mainStackView.alignment = .center

        contentView.addSubview(mainStackView)
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mainStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            mainStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            mainStackView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9)
        ])
        
        NSLayoutConstraint.activate([
            saveButton.widthAnchor.constraint(equalToConstant: 30),
            saveButton.heightAnchor.constraint(equalToConstant: 30),
            
            soundButton.widthAnchor.constraint(equalToConstant: 30),
            soundButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with word: Word) {
        wordLabel.text = word.word
        definitionLabel.text = word.definition
        phoneticsLabel.text = word.phonetic
    }
    
    @objc private func saveButtonTapped() {
        onSaveTapped?()
    }
    
    @objc private func soundButtonTapped() {
        onSoundTapped?()
    }
}


#Preview {
    ContentView()
}
