//
//  ContentViewModel.swift
//  Wordify
//
//  Created by Chris Rowley on 11/27/24.
//

import Foundation
import SwiftData
import SwiftUI

extension ContentView{
    
    @Observable
    class ViewModel {
        func loadGreJSON() -> Data? {
            if let url = Bundle.main.url(forResource: "word_data", withExtension: ".json"){
                do {
                    return try Data(contentsOf: url)
                } catch {
                    print("Error loading JSON: \(error.localizedDescription)")
                    return nil
                }
            }
            return nil
        }
        
        func parseJSONData(_ data: Data) -> [JSONData]? {
            do {
                let decoder = JSONDecoder()
                return try decoder.decode([JSONData].self, from: data)
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
                return nil
            }
        }
        
        @MainActor
        func importWordData(from data: Data, context: ModelContext) async throws {
            if let jsonWords = parseJSONData(data){
                for jsonWord in jsonWords{
                    let newWord = Word(word: jsonWord.word, audio: jsonWord.audio, phonetic: jsonWord.phonetic, definition: jsonWord.definition, difficultyLevel: jsonWord.difficultyLevel, wordType: jsonWord.type, example: jsonWord.example)
                    context.insert(newWord)
                }
                
                do{
                    try context.save()
                    print("Successfuly saved word")
                } catch {
                    print("error saving word: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    struct JSONData: Codable {
        
        var word: String
        var audio: String
        var phonetic: String
        var definition: String
        var type: String
        var difficultyLevel: String
        var example: String
    }
}
