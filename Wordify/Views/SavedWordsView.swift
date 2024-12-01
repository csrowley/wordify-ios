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
    @Query(filter: #Predicate<Word> { word in
        word.isFavorite == true
    }) private var savedWords: [Word]
    
    var body: some View {
        List(savedWords) { word in
            VStack(alignment: .leading) {
                Text(word.word)
                    .font(.headline)
                Text(word.definition)
                    .font(.subheadline)
            }
        }
    }
}

#Preview {
    SavedWordsView()
}
