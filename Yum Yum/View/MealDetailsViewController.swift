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
    var meal: Meal? = nil
    var idOFMeal: String? = nil
    var mealDetails: MealDetails? = nil
    var ingredientsList: [String]? = nil
    var favoritedMeals: [FavoritedMeals] = []
    private var hasFavoritedMeal: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getFavoritedMeals()
        self.getMealDetails()
        self.mealNameLabel.text = ""
        self.mealOriginLabel.text = ""
        self.mealCategoryLabel.text = ""
        self.mealIngredientsLabel.text = ""
        self.mealIngredientsTextView.text = ""
        self.mealInstructionsLabel.text = ""
        self.mealInstructionsTextView.text = ""
    }
    
    @objc private func favoriteMealAction() -> Void {
        let meal = self.mealDetails
        //remove meal from favorites if it already exists; otherwise add meal to favorites
        if self.hasFavoritedMeal {
            self.unfavoriteMeal(mealID: (meal?.idMeal)!)
            self.hasFavoritedMeal = false
        } else {
            //prevent duplicate meal additions to favorites
            self.saveMealToFavorites(mealItem: meal!)
            self.hasFavoritedMeal = true
        }
        self.updateFavoriteButton(toggleValue: self.hasFavoritedMeal)
    }
    
    func unfavoriteMeal(mealID: String) -> Void {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
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
    
    private func getFavoritedMeals() -> Void {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest = NSFetchRequest<FavoritedMeals>(entityName: "FavoritedMeals")
        
        do {
            self.favoritedMeals = try managedContext.fetch(fetchRequest)
        } catch {
            print("Could not retrieve favorited meals from storage")
        }
    }
    
    private func saveMealToFavorites(mealItem: MealDetails) -> Void {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "FavoritedMeals", in: managedContext)!
        let meal = FavoritedMeals(entity: entity, insertInto: managedContext)
        meal.setValue(mealItem.idMeal, forKey: "mealID")
        meal.setValue(mealItem.strMealEdited, forKey: "mealName")
        
        do {
            try managedContext.save()
        } catch {
            print("Could not save meal into favorites")
        }
    }
    
    
    
    private func getRemoteImage(mealImageURL: String) -> Data {
        guard let imageURL: URL = URL(string: mealImageURL) else {
            return Data()
        }
        guard let imageData: Data = try? Data(contentsOf: imageURL) else {
            return Data()
        }
        
        return imageData
    }
    
    private func getMealDetails() -> Void {
        var mealID: String = ""
        
        if self.idOFMeal == nil {
            mealID = self.meal!.idMeal
        } else {
            mealID = self.idOFMeal!
        }
        
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(String(describing: mealID))") else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            do {
                let decodedResponse = try JSONDecoder().decode(MealDetailsCollection.self, from: data)
                self.mealDetails = decodedResponse.meals[0]
                DispatchQueue.main.async {
                    self.mealImageView.image = UIImage(data: self.getRemoteImage(mealImageURL: self.mealDetails?.strMealThumb ?? ""))?.roundedImage
                    self.mealNameLabel.text = self.mealDetails?.strMealEdited
                    self.mealCategoryLabel.text = "Category: \(self.mealDetails?.strCategory ?? "N/A")"
                    self.mealOriginLabel.text = "Origin: \(self.mealDetails?.strArea ?? "N/A")"
                    self.mealIngredientsLabel.text = "Ingredients"
                    self.mealIngredientsTextView.text = "Some ingredients..."
                    self.mealInstructionsLabel.text = "Instructions"
                    self.mealIngredientsTextView.text = self.createIngredientList(data: self.mealDetails!)
                    self.mealInstructionsTextView.text = self.mealDetails?.strInstructions
                    self.hasFavoritedMeal = self.favoritedMeals.contains(where: { $0.mealID == self.mealDetails?.idMeal })
                    self.updateFavoriteButton(toggleValue: self.hasFavoritedMeal)
                }
            } catch let error {
                print(error)
            }
        }
        task.resume()
    }
    
    private func updateFavoriteButton(toggleValue: Bool) -> Void {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: toggleValue ? "star.fill" : "star"), style: .plain, target: self, action: #selector(self.favoriteMealAction))
    }
    
    private func createIngredientList(data: MealDetails) -> String {
        var combinedIngredients: [String] = []
        
        for ingredient in data.allIngredients {
            if ingredient != " - " && ingredient != " -  " {
                if hasIncompleteIngredientComponent(for: ingredient!){
                    combinedIngredients.append(String(cleanUpIngredient(for: ingredient!)))
                } else {
                    combinedIngredients.append(ingredient!)
                }
            }
        }
        return combinedIngredients.joined(separator: "\n")
    }
    
    private func hasIncompleteIngredientComponent(for text: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z]+ - $", options: [.caseInsensitive])
        let range = NSRange(location: 0, length: text.count)
        let matches = regex.matches(in: text, options: [], range: range)
        return matches.first != nil
    }
    
    func cleanUpIngredient(for ingredient: String) -> Substring {
        let cleanedString = ingredient.dropLast(3)
        return cleanedString
    }
}

/*
 following extension found at:
 https://medium.com/@ahmedmuslimani609/rounded-corner-images-and-why-it-kills-your-app-248750884379
 */
extension UIImage{
    var roundedImage: UIImage {
        let rect = CGRect(origin:CGPoint(x: 0, y: 0), size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
        UIBezierPath(
            roundedRect: rect,
            cornerRadius: 15
        ).addClip()
        self.draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}
