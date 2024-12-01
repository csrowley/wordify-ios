//
//  Word.swift
//  Wordify
//
//  Created by Chris Rowley on 11/28/24.
//

import Foundation
import SwiftData


@Model
final class Word {
    @Attribute(.unique) var id: UUID
    var word: String
    var audio: String
    var phonetic: String
    var definition: String
    var difficultyLevel: String
    var wordType: String
    var example: String
    var isFavorite: Bool = false
    
    //@Relationship var category: Category?
    
    init(id: UUID = UUID(), word: String, audio: String, phonetic: String, definition: String, difficultyLevel: String, wordType: String, example: String) {
        self.id = id
        self.word = word
        self.audio = audio
        self.phonetic = phonetic
        self.definition = definition
        self.difficultyLevel = difficultyLevel
        self.wordType = wordType
        self.example = example
    }
}

@Model
final class Favorite {
    @Attribute(.unique) var id: UUID
    var word: Word
    
    init(id: UUID = UUID(), word: Word) {
        self.id = id
        self.word = word
    }
}

//@Model
//final class Category: {
//    @Attribute(.unique) var id: UUID
//    var name: String
//    
//    init(id: UUID = UUID(), name: String) {
//        self.id = id
//        self.name = name
//    }
//}
