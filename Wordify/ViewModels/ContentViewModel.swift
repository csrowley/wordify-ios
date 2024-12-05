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
        func importWordData(from data: Data, context: ModelContext, categoryType: String) async throws {
            if let jsonWords = parseJSONData(data){
                for jsonWord in jsonWords{
                    let newWord = Word(word: jsonWord.word, audio: jsonWord.audio, phonetic: jsonWord.phonetic, definition: jsonWord.definition, category: jsonWord.category, wordType: jsonWord.type, example: jsonWord.example)
                    context.insert(newWord)
                }
                
                let newCategory = Category(category: categoryType)
                context.insert(newCategory)
                
                do{
                    try context.save()
                    print("Successfuly saved word and category")
                } catch {
                    print("error saving word or category: \(error.localizedDescription)")
                }
            }
        }
        
        func checkForStreakUpdate(lastLoginDateStr: String) -> Int {
//            let currentDate = Date()
            let calendar = Calendar.current
            let current = Date()
            
            guard !lastLoginDateStr.isEmpty else {
                return -1
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-mm-dd"
            
            guard let lastLoginDate = formatter.date(from: lastLoginDateStr) else {
                return -1
            }
            
            let components = calendar.dateComponents([.day], from: current, to: lastLoginDate)
            
            // Returns amount of days since last login
            if let timeSince = components.day {
                return timeSince
            }
            
            return -1
        }
    }
    
    
    struct JSONData: Codable {
        
        var word: String
        var audio: String
        var phonetic: String
        var definition: String
        var type: String
        var category: String
        var example: String
    }
}
