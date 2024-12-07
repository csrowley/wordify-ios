//
//  SavedWordsView.swift
//  Wordify
//
//  Created by Chris Rowley on 11/28/24.
//

import Foundation
import SwiftUI
import SwiftData

struct SavedWordsView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) private var colorScheme
    var wordFavoriteUpdator: WordFavoritingProtocol?
    
    let jetBlack = UIColor(red:0.145, green: 0.145, blue: 0.145, alpha: 1)
    let seashell = UIColor(red: 1, green: 0.945, blue: 0.906, alpha: 1)
    var saveButton: UIButton?
    
    @Query(filter: #Predicate<Word> { word in
        word.isFavorite == true
    }) private var savedWords: [Word]
    @Query var categories: [Category]
    
    var body: some View {
        NavigationStack {
            List(savedWords) { word in
                VStack(alignment: .leading) {
                    Text(word.word)
                        .font(Font.custom("NewsreaderRoman-SemiBold", size: 20))
                        .padding(.bottom, 2)
                    Text(word.wordType)
                        .font(Font.custom("Newsreader16pt-Italic", size:16))

                        .padding(.bottom, 2)
                    Text(word.definition)
                        .font(Font.custom("Newsreader16pt-Regular", size:16))
                }
                .listRowBackground(colorScheme == .dark ? Color(jetBlack) : .white)
                .swipeActions(edge: .trailing, allowsFullSwipe: true){
                    Button(role: .destructive){
                        unFavorite(word)
                        
                        print(categories)
                        
                    } label : {
                        Label("Unfavorite", systemImage: "heart.slash")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(seashell))
        }
    }
    
    
    private func unFavorite(_ word: Word) {
        word.isFavorite = false
        try? modelContext.save()
        
        // Post notification
        NotificationCenter.default.post(
            name: Notification.Name("WordFavoriteStatusChanged"),
            object: nil,
            userInfo: ["word": word]
        )
    }
}

#Preview {
    SavedWordsView()
}
