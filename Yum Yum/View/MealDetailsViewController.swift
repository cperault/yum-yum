//
//  MealDetailsViewController.swift
//  Yum Yum
//
//  Created by Christopher Perault on 12/11/21.
//

import UIKit
import CoreData

class MealDetailsViewController: UIViewController {
    @IBOutlet var mealImageView: UIImageView!
    @IBOutlet var mealNameLabel: UILabel!
    @IBOutlet var mealCategoryLabel: UILabel!
    @IBOutlet var mealOriginLabel: UILabel!
    @IBOutlet var mealIngredientsLabel: UILabel!
    @IBOutlet var mealIngredientsTextView: UITextView!
    @IBOutlet var mealInstructionsLabel: UILabel!
    @IBOutlet var mealInstructionsTextView: UITextView!
    var mealID: String? = nil
    var mealDetails: MealDetails? = nil
    var ingredientsList: [String]? = nil
    var favoritedMeals: [FavoritedMeals] = []
    private var hasFavoritedMeal: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getFavoritedMeals()
        self.getMealDetails()
        self.clearLabelTextValues()
    }
    
    private func getFavoritedMeals() -> Void {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest = NSFetchRequest<FavoritedMeals>(entityName: "FavoritedMeals")
        
        do {
            self.favoritedMeals = try managedContext.fetch(fetchRequest)
        } catch {
            print("Could not retrieve favorited meals from storage")
        }
    }
    
    private func getMealDetails() -> Void {
        if let mealID = mealID {
            URLSession.shared.requestWithParams(url: URLConstants.mealDetailsURL, parameters: ["i": mealID], expectedEncodingType: MealDetailsCollection.self) { (result: Result<MealDetailsCollection, Error>) in
                switch result {
                    case .success(let response):
                        self.mealDetails = response.meals[0]
                        DispatchQueue.main.async {
                            self.mealImageView.image = getRemoteImage(mealImageURL: self.mealDetails?.strMealThumb ?? "")
                            self.mealNameLabel.text = self.mealDetails?.strMealEdited
                            self.mealCategoryLabel.text = "Category: \(self.mealDetails?.strCategory ?? "N/A")"
                            self.mealOriginLabel.text = "Origin: \(self.mealDetails?.strArea ?? "N/A")"
                            self.mealIngredientsLabel.text = "Ingredients"
                            self.mealIngredientsTextView.text = self.mealDetails?.ingredientList
                            self.mealInstructionsLabel.text = "Instructions"
                            self.mealInstructionsTextView.text = self.mealDetails?.strInstructions
                            self.hasFavoritedMeal = self.favoritedMeals.contains(where: { $0.mealID == self.mealDetails?.idMeal })
                            self.updateFavoriteButton(toggleValue: self.hasFavoritedMeal)
                        }
                    case .failure(let error):
                        print(error)
                }
            }
        }
    }
    
    private func clearLabelTextValues() -> Void {
        self.mealNameLabel.text = ""
        self.mealOriginLabel.text = ""
        self.mealCategoryLabel.text = ""
        self.mealIngredientsLabel.text = ""
        self.mealIngredientsTextView.text = ""
        self.mealInstructionsLabel.text = ""
        self.mealInstructionsTextView.text = ""
    }
    
    @objc private func favoriteMealAction() -> Void {
        guard let meal = self.mealDetails else { return }
        //remove meal from favorites if it already exists; otherwise add meal to favorites
        if self.hasFavoritedMeal {
            self.unfavoriteMeal(mealItem: meal)
            self.hasFavoritedMeal = false
        } else {
            //prevent duplicate meal additions to favorites
            self.saveMealToFavorites(mealItem: meal)
            self.hasFavoritedMeal = true
        }
        self.updateFavoriteButton(toggleValue: self.hasFavoritedMeal)
    }
    
    private func saveMealToFavorites(mealItem: MealDetails) -> Void {
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
    
    private func unfavoriteMeal(mealItem: MealDetails) -> Void {
        guard let mealItemID = mealItem.idMeal else { return }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<FavoritedMeals>(entityName: "FavoritedMeals")
        fetchRequest.predicate = NSPredicate(format:"mealID = %@", mealItemID)
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
    
    private func updateFavoriteButton(toggleValue: Bool) -> Void {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: toggleValue ? "star.fill" : "star"), style: .plain, target: self, action: #selector(self.favoriteMealAction))
    }
}
