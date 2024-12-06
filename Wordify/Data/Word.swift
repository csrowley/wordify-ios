//
//  Word.swift
//  Wordify
//
//  Created by Chris Rowley on 11/28/24.
//

import Foundation
import SwiftData

/// On Main screen, we can have a label displaying the selected category,
/// On Category screen, we will  have a list of all categories and allow the user to select the specific category? (Category screen can also be removed and we can just use a drop down picker with the category button on main screen) (premium categories will have a lock icon next to it)
///

@Model
final class Word: Identifiable{
    @Attribute(.unique) var id: UUID
    var word: String
    var audio: String
    var phonetic: String
    var definition: String
    var category: String
    var wordType: String
    var example: String
    var isFavorite: Bool = false
    
    var parentCategory: Category
    
    init(id: UUID = UUID(), word: String, audio: String, phonetic: String, definition: String, category: String, wordType: String, example: String, parentCategory: Category) {
        self.id = id
        self.word = word
        self.audio = audio
        self.phonetic = phonetic
        self.definition = definition
        self.category = category
        self.wordType = wordType
        self.example = example
        self.parentCategory = parentCategory
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

@Model
final class Category {
    var id: UUID
    var category: String
    var word_list: [Word]
    init(id: UUID = UUID(), category: String, word_list: [Word] = []) {
        self.id = id
        self.category = category
        self.word_list = word_list
    }
}
