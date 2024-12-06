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
        func loadJSON(from fileName: String) -> Data? {
            if let url = Bundle.main.url(forResource: fileName, withExtension: ".json"){
                do {
                    return try Data(contentsOf: url)
                } catch {
                    print("Error loading JSON: \(error.localizedDescription)")
                    return nil
                }
            }
            return nil
        }
        
        func checkIfCategoryExists(name: String, from context: ModelContext) -> Category? {
            var descriptor = FetchDescriptor<Category>(
                predicate: #Predicate<Category> { category in
                    category.category == name
                }
            )
            descriptor.fetchLimit = 1
            
            do {
                let result = try context.fetch(descriptor).first
                return result
            } catch {
                print("error finding specified category", error)
                return nil
            }
            
            
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
            if let jsonWords = parseJSONData(data) {
                // First, check if the category exists
                var parentCategory = checkIfCategoryExists(name: categoryType, from: context)
                
                // If category doesn't exist, create it
                if parentCategory == nil {
                    parentCategory = Category(category: categoryType)
                    context.insert(parentCategory!)
                }
                
                for jsonWord in jsonWords {
                    let newWord = Word(
                        word: jsonWord.word,
                        audio: jsonWord.audio,
                        phonetic: jsonWord.phonetic,
                        definition: jsonWord.definition,
                        category: categoryType,  // Use the category type here
                        wordType: jsonWord.type,
                        example: jsonWord.example,
                        parentCategory: parentCategory! //already handeled above (force wrap ok)
                    )
                    parentCategory!.word_list.append(newWord)
                    context.insert(newWord)
                }
                
                
                
                do {
                    try context.save()
                    print("Successfully saved words and category")
                } catch {
                    print("Error saving word or category: \(error.localizedDescription)")
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
