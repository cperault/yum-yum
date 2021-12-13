//
//  MealDetailsViewController.swift
//  Yum Yum
//
//  Created by Christopher Perault on 12/11/21.
//

import UIKit

class MealDetailsViewController: UIViewController {
    @IBOutlet var mealImageView: UIImageView!
    @IBOutlet var mealNameLabel: UILabel!
    @IBOutlet var mealCategoryLabel: UILabel!
    @IBOutlet var mealOriginLabel: UILabel!
    @IBOutlet var mealIngredientsLabel: UILabel!
    @IBOutlet var mealIngredientsTextView: UITextView!
    @IBOutlet var mealInstructionsLabel: UILabel!
    @IBOutlet var mealInstructionsTextView: UITextView!
    var meal: Meal?
    var mealDetails: MealDetails?
    var ingredientsList: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mealNameLabel.text = ""
        self.mealOriginLabel.text = ""
        self.mealCategoryLabel.text = ""
        self.mealIngredientsLabel.text = ""
        self.mealIngredientsTextView.text = ""
        self.mealInstructionsLabel.text = ""
        self.mealInstructionsTextView.text = ""
        getMealDetails()
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
        let url = URL(string: "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(meal!.idMeal)")!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            do {
                let decodedResponse = try JSONDecoder().decode(MealDetailsCollection.self, from: data)
                self.mealDetails = decodedResponse.meals[0]
                DispatchQueue.main.async {
                    self.mealImageView.image = UIImage(data: self.getRemoteImage(mealImageURL: self.mealDetails?.strMealThumb ?? ""))
                    self.mealImageView.layer.cornerRadius = 15
                    self.mealImageView.clipsToBounds = true
                    self.mealNameLabel.text = self.mealDetails?.strMealEdited
                    self.mealCategoryLabel.text = "Category: \(self.mealDetails?.strCategory ?? "N/A")"
                    self.mealOriginLabel.text = "Origin: \(self.mealDetails?.strArea ?? "N/A")"
                    self.mealIngredientsLabel.text = "Ingredients"
                    self.mealIngredientsTextView.text = "Some ingredients..."
                    self.mealInstructionsLabel.text = "Instructions"
                    self.mealIngredientsTextView.text = self.createIngredientList(data: self.mealDetails!)
                    self.mealInstructionsTextView.text = self.mealDetails?.strInstructions
                }
            } catch let error {
                print(error)
            }
        }
        task.resume()
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
