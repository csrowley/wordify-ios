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
