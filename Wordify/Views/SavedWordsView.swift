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
    @Environment(\.colorScheme) private var colorScheme
    
    let jetBlack = UIColor(red:0.145, green: 0.145, blue: 0.145, alpha: 1)
    let seashell = UIColor(red: 1, green: 0.945, blue: 0.906, alpha: 1)
    
    @Query(filter: #Predicate<Word> { word in
        word.isFavorite == true
    }) private var savedWords: [Word]
    
    var body: some View {
        NavigationStack {
            List(savedWords) { word in
                VStack(alignment: .leading) {
                    Text(word.word)
                        .font(.headline)
                    Text(word.definition)
                        .font(.subheadline)
                }
                .listRowBackground(colorScheme == .dark ? Color(jetBlack) : .white)
            }
            .scrollContentBackground(.hidden)
            .background(Color(seashell))
        }
//        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    SavedWordsView()
}
