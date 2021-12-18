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
        self.clearLabelTextValues()
        self.getFavoritedMeals()
        self.getMealDetails()
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
            guard let idOfMeal = meal.idMeal else { return }
            unfavoriteMeal(mealID: idOfMeal)
            self.hasFavoritedMeal = false
        } else {
            //prevent duplicate meal additions to favorites
            saveMealToFavorites(mealItem: meal)
            self.hasFavoritedMeal = true
        }
        self.updateFavoriteButton(toggleValue: self.hasFavoritedMeal)
    }
    
    private func updateFavoriteButton(toggleValue: Bool) -> Void {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: toggleValue ? "star.fill" : "star"), style: .plain, target: self, action: #selector(self.favoriteMealAction))
    }
}
