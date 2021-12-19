//
//  MealListTableViewController.swift
//  Yum Yum
//
//  Created by Christopher Perault on 12/10/21.
//

import UIKit

class MealListTableViewController: UITableViewController {
    var category: String?
    private var meals: [Meal] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.getMeals()
    }
    
    private func getMeals() -> Void {
        if let category = self.category {
            URLSession.shared.requestWithParams(url: URLConstants.mealsByCategoryURL, parameters: ["c": category.lowercased()], expectedEncodingType: Meals.self) { (result: Result<Meals, Error>) in
                switch result {
                    case .success(let response):
                        self.meals = response.meals.sorted()
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    case .failure(let error):
                        print(error)
                }
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MealListCell") as! MealListTableViewCell
        cell.mealNameLabel.text = meals[indexPath.row].strMealEdited
        cell.meal = meals[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let mealDetailsVC = storyboard?.instantiateViewController(withIdentifier: "MealDetailsViewController") as? MealDetailsViewController else { return }
        let selectedMeal: Meal = meals[indexPath.row]
        mealDetailsVC.mealID = selectedMeal.idMeal
        navigationController?.pushViewController(mealDetailsVC, animated: true)
    }
}
