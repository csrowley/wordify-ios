//
//  WordCell.swift
//  Wordify
//
//  Created by Chris Rowley on 12/5/24.
//

import UIKit
import Foundation
import SwiftData
import AVFoundation
import SwiftUI

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

    private let categoryButton = PickerButton()
    
    var currentWord: Word?
    
    var onSaveTapped:  (() -> Void)?
    var onSoundTapped:  (() -> Void)?
    
    var onCategorySelected: ((Category) -> Void)?

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
        categoryButton.addTarget(self, action: #selector(newCategoryButtonTapped), for: .touchUpInside)
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
            soundButton.heightAnchor.constraint(equalToConstant: 30),
            
            categoryButton.widthAnchor.constraint(equalToConstant: 30),
            categoryButton.heightAnchor.constraint(equalToConstant: 30)
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
        
        categoryButton.onCategorySelected = { [weak self] category in
            self?.onCategorySelected?(category)
        }
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
    
    @objc private func newCategoryButtonTapped() {
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
    
    func configureCategoryButton(with categories: [Category]){
        categoryButton.setup(systemIcon: "books.vertical", data: categories)
        
        categoryButton.onCategorySelected = { [weak self] category in
            self?.onCategorySelected?(category)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        NotificationCenter.default.removeObserver(self)
    }
    
}

