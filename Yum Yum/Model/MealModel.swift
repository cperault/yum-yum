//
//  MealModel.swift
//  Yum Yum
//
//  Created by Christopher Perault on 12/9/21.
//

import Foundation
import UIKit
import CoreData

struct Meal: Codable, Comparable {
    static func < (lhs: Meal, rhs: Meal) -> Bool {
        return lhs.strMeal < rhs.strMeal
    }
    
    let strMeal: String
    let strMealThumb: String
    let idMeal: String
    
    var strMealEdited: String {
        return capitalizedWords(stringToEdit: strMeal)
    }
}

struct Meals: Codable {
    let meals: [Meal]
}

struct MealDetails: Codable, Comparable {
    static func < (lhs: MealDetails, rhs: MealDetails) -> Bool {
        return lhs.strMeal < rhs.strMeal
    }
    
    let idMeal: String?
    let strMeal: String
    let strDrinkAlternate: String?
    let strCategory: String?
    let strArea: String?
    let strInstructions: String?
    let strMealThumb: String?
    let strTags: String?
    let strYoutube: String?
    let strIngredient1: String?
    let strIngredient2: String?
    let strIngredient3: String?
    let strIngredient4: String?
    let strIngredient5: String?
    let strIngredient6: String?
    let strIngredient7: String?
    let strIngredient8: String?
    let strIngredient9: String?
    let strIngredient10: String?
    let strIngredient11: String?
    let strIngredient12: String?
    let strIngredient13: String?
    let strIngredient14: String?
    let strIngredient15: String?
    let strIngredient16: String?
    let strIngredient17: String?
    let strIngredient18: String?
    let strIngredient19: String?
    let strIngredient20: String?
    let strMeasure1: String?
    let strMeasure2: String?
    let strMeasure3: String?
    let strMeasure4: String?
    let strMeasure5: String?
    let strMeasure6: String?
    let strMeasure7: String?
    let strMeasure8: String?
    let strMeasure9: String?
    let strMeasure10: String?
    let strMeasure11: String?
    let strMeasure12: String?
    let strMeasure13: String?
    let strMeasure14: String?
    let strMeasure15: String?
    let strMeasure16: String?
    let strMeasure17: String?
    let strMeasure18: String?
    let strMeasure19: String?
    let strMeasure20: String?
    let strSource: String?
    let strImageSource: String?
    let strCreativeCommonsConfirmed: String?
    let dateModified: String?
    
    var allTags: [String] {
        return strTags?.components(separatedBy: ",") ?? [""]
    }
    
    var strMealEdited: String {
        return capitalizedWords(stringToEdit: strMeal)
    }
    
    var allIngredients: [String?] {
        return [
            strIngredient1, strIngredient2, strIngredient3, strIngredient4,
            strIngredient5, strIngredient6, strIngredient7, strIngredient8,
            strIngredient9, strIngredient10, strIngredient11, strIngredient12,
            strIngredient13, strIngredient14, strIngredient15, strIngredient16,
            strIngredient17, strIngredient18, strIngredient19, strIngredient20,
        ]
    }
    
    var allMeasurements: [String?] {
        return [
            strMeasure1, strMeasure2, strMeasure3, strMeasure4,
            strMeasure5, strMeasure6, strMeasure7, strMeasure8,
            strMeasure9, strMeasure10, strMeasure11, strMeasure12,
            strMeasure13, strMeasure14, strMeasure15, strMeasure16,
            strMeasure17, strMeasure18, strMeasure19, strMeasure20,
        ]
    }
    
    var ingredientList: String {
        return createIngredientsList()
    }
    
    func createIngredientsList() -> String {
        var ingredientsList: [String] = []
        let ingredients: [String?] = allIngredients
        let measurements: [String?] = allMeasurements
        
        for index in stride(from: 0, to: 20, by: 1) {
            if measurements[index]?.trimmingCharacters(in: .whitespacesAndNewlines) != "" && measurements[index] != nil {
                ingredientsList.append("\(capitalizedWords(stringToEdit: ingredients[index]!)) - \(measurements[index]!)")
            } else if ingredients[index] != "" && ingredients[index] != nil {
                ingredientsList.append("\(capitalizedWords(stringToEdit: ingredients[index]!))")
            }
        }
        return ingredientsList.joined(separator: "\n")
    }
}


struct MealDetailsCollection: Codable {
    let meals: [MealDetails]
}

func unfavoriteMeal(mealID: String) -> Void {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let managedContext = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<FavoritedMeals>(entityName: "FavoritedMeals")
    fetchRequest.predicate = NSPredicate(format:"mealID = %@", mealID)
    var results: [FavoritedMeals] = []
    
    do {
        results = try managedContext.fetch(fetchRequest)
    } catch {
        print("Could not complete fetch request")
    }
    
    if results.count > 0 {
        managedContext.delete(results[0]) //`.delete()` does not throw
        
        do {
            try managedContext.save()
        } catch {
            print("Could not save after deletion")
        }
    }
}

func saveMealToFavorites(mealItem: MealDetails) -> Void {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    
    let managedContext = appDelegate.persistentContainer.viewContext
    guard let entity = NSEntityDescription.entity(forEntityName: "FavoritedMeals", in: managedContext) else { return }
    let meal = FavoritedMeals(entity: entity, insertInto: managedContext)
    meal.setValue(mealItem.idMeal, forKey: "mealID")
    meal.setValue(mealItem.strMealEdited, forKey: "mealName")
    
    do {
        try managedContext.save()
    } catch {
        print("Could not save meal into favorites")
    }
}

