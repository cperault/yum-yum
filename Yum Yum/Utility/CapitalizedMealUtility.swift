//
//  CapitalizedMealUtility.swift
//  Yum Yum
//
//  Created by Christopher Perault on 12/17/21.
//

import Foundation

func capitalizedWords(stringToEdit: String) -> String {
    let words: [String] = stringToEdit.components(separatedBy: [" "])
    var wordsEdited: [String] = []
    let excludedWords: [String] = ["with", "and", "in"]
    
    for word in words {
        wordsEdited.append(!excludedWords.contains(word.lowercased()) ? word.capitalized : word.lowercased())
    }
    
    return wordsEdited.joined(separator: " ")
}
