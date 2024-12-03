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
    @Environment(\.modelContext) var modelContext
    @Query var wordData: [Word]
    
    @State private var viewModel = ViewModel()
    @State private var favoritingUpdator: WordFavoritingProtocol?
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
                    .background(Color(seashell))
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
                
                
                SavedWordsView() //insert ui Button
                    .tabItem{
                        Label("Saved", systemImage: "bookmark")
                    }
                
                Text("Hello:")
                    .tabItem{
                        Label("Quiz", systemImage: "graduationcap")
                    }
                
                Text("Hello:")
                    .tabItem{
                        Label("Categories", systemImage: "books.vertical")
                    }
                
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Wordify") // Set your title here
                        .font(Font.custom("NewsreaderRoman-SemiBold", size: 40))
                        .padding(.top)
                        .foregroundStyle(Color(jetBlack))
                }
                
                ToolbarItem(placement: .topBarLeading){
                    Button {
                        // take to profile view (use navlink?)
                    } label: {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width:30, height:30)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(Color(navyBlue))
                    }
                    .padding(.top)
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
                        .padding(.top)
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


    var words: [Word]
    
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
        
        if lastScrollIndex > 0 && lastScrollIndex < words.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                collectionViewController.collectionView.scrollToItem(
                    at: IndexPath(item: lastScrollIndex, section: 0),
                    at: .top,
                    animated: false
                )
            }
        }
        else if lastScrollIndex >= words.count - 1 {
            print("resettings scroll index to 0")
            lastScrollIndex = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                collectionViewController.collectionView.scrollToItem(
                    at: IndexPath(item: 0, section: 0),
                    at: .top,
                    animated: false
                )
            }
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
            let word = parent.words[indexPath.item]
            
            // Check if the word is already a favorite
            
            cell.configure(with: word)
            
            cell.onSaveTapped =  { [weak self] in
                word.isFavorite.toggle()
                do {
                    try? self?.modelContext.save()
                    cell.configure(with: word)
                    
                } catch {
                    print("error saving favorite: \(error.localizedDescription)")
                }
            }
            
            
            return cell
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            let page = Int(scrollView.contentOffset.y / scrollView.bounds.height)
            parent.lastScrollIndex = page
        }
        
    }
    
}

// Custom UICollectionView Cell
class WordCell: UICollectionViewCell{
    @Environment(\.modelContext) var modelContext
    
    private var audioPlayer: AVPlayer?
    
    let charcoal = UIColor(red:0.29, green: 0.29, blue: 0.29, alpha: 1)
    let jetBlack = UIColor(red:0.145, green: 0.145, blue: 0.145, alpha: 1)

    
    private let wordLabel = UILabel()
    private let definitionLabel = UILabel()
    private let phoneticsLabel = UILabel()
    private let partOfSpeachLabel = UILabel()
    private let exampleLabel = UILabel()
    
    private let saveButton = UIButton(type: .system)
    private let soundButton = UIButton(type: .system)
    private let categoryButton = UIButton(type: .system)
    
     var currentWord: Word?
    
    var onSaveTapped:  (() -> Void)?
    var onSoundTapped:  (() -> Void)?
    var onCategoryTapped:  (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        wordLabel.font = UIFont(name:"Newsreader16pt-Regular", size:40)
        wordLabel.textColor = jetBlack
        wordLabel.textAlignment = .center

        
        definitionLabel.font = UIFont(name:"Newsreader16pt-Regular", size:24)
        definitionLabel.textColor = charcoal
        definitionLabel.textAlignment = .center
        definitionLabel.numberOfLines = 0
        
        
        phoneticsLabel.font = UIFont(name:"Newsreader16pt-Italic", size:20)
        phoneticsLabel.textColor = jetBlack
        phoneticsLabel.textAlignment = .center
        phoneticsLabel.numberOfLines = 0
        
        
        exampleLabel.font = UIFont(name:"Newsreader16pt-Italic", size:20)
        exampleLabel.textColor = charcoal
        exampleLabel.textAlignment = .center
        exampleLabel.numberOfLines = 0
        
        
        saveButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
        saveButton.tintColor = .black
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        saveButton.contentMode = .scaleAspectFit
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.isSymbolAnimationEnabled = true

        
        
        soundButton.setImage(UIImage(systemName: "speaker.wave.2"), for: .normal)
        soundButton.tintColor = .black
        soundButton.addTarget(self, action: #selector(soundButtonTapped), for: .touchUpInside)
        soundButton.contentMode = .scaleAspectFit
        soundButton.translatesAutoresizingMaskIntoConstraints = false
        soundButton.isSymbolAnimationEnabled = true
        
        categoryButton.setImage(UIImage(systemName: "books.vertical"), for: .normal)
        categoryButton.tintColor = .black
        categoryButton.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
        categoryButton.contentMode = .scaleAspectFit
        categoryButton.translatesAutoresizingMaskIntoConstraints = false
        categoryButton.isSymbolAnimationEnabled = true

        
        let buttonStackView = UIStackView(arrangedSubviews: [saveButton, soundButton, categoryButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 25
        buttonStackView.alignment = .center
        
        let mainStackView = UIStackView(arrangedSubviews: [wordLabel, phoneticsLabel, definitionLabel, exampleLabel, buttonStackView])
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        mainStackView.alignment = .center
        


        contentView.addSubview(mainStackView)
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mainStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            mainStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            mainStackView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9),
            

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
        currentWord = word
        updateUI() // Move all UI updates to a separate method
        
        // Remove old observer before adding new one
        NotificationCenter.default.removeObserver(self)
        
        // Use SwiftData's notification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(modelContextDidChange),
            name: Notification.Name("WordFavoriteStatusChanged"), // Custom notification name
            object: nil
        )
    }
    
    @objc private func saveButtonTapped() {
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Animation
        UIView.animate(withDuration: 0.1, animations: {
            self.saveButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.saveButton.transform = .identity
            }
        }
        if let word = currentWord {
            onSaveTapped?()
        }
    }
    
    @objc private func soundButtonTapped() {
        
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Animation
        UIView.animate(withDuration: 0.1, animations: {
            self.soundButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.soundButton.transform = .identity
            }
        }
        
        
        guard let word = currentWord,
              let audioURL = URL(string: word.audio) else {
            print("Error loading audio")
            return
        }
        
        let playerItem = AVPlayerItem(url: audioURL)
        audioPlayer = AVPlayer(url: audioURL)
                
        audioPlayer?.play()
        
        onSoundTapped?()
    }
    
    @objc private func categoryButtonTapped() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Animation
        UIView.animate(withDuration: 0.1, animations: {
            self.categoryButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.categoryButton.transform = .identity
            }
        }
        
        onCategoryTapped?()
    }
    
    @objc private func modelContextDidChange() {
        updateUI()
    }
    
    private func updateUI() {
        guard let word = currentWord else { return }
        wordLabel.text = word.word
        definitionLabel.text = "(\(word.wordType)) \(word.definition)"
        phoneticsLabel.text = word.phonetic
        exampleLabel.text = "\(word.example)"
        
        let saveButtonImage = word.isFavorite ?
            UIImage(systemName: "bookmark.fill") :
            UIImage(systemName: "bookmark")
        
        saveButton.setImage(saveButtonImage, for: .normal)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        NotificationCenter.default.removeObserver(self)
    }
    
}


#Preview {
    ContentView()
}
