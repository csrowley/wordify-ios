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
    @Query var savedWords: [Word]
    
    var body: some View {
        VStack {
            if savedWords.isEmpty {
                Text("No saved words yet.")
                    .foregroundColor(.gray)
            } else {
                ForEach(savedWords) { word in
                    Text(word.word)
                }
            }
        }
    }
}

#Preview {
    SavedWordsView()
}
