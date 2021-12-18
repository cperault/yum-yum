//
//  AllMealsTableViewController.swift
//  Yum Yum
//
//  Created by Christopher Perault on 12/11/21.
//

import UIKit

class AllMealsTableViewController: UITableViewController {
    private var selectedMeal: String?
    var meals: [Meal] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        getAllMeals()
    }
    
    private func getAllMeals() -> Void {
        let mealData = getFileBundleData(fileName: "meals", fileExtension: "json", expectedEncodingType: Meals.self)
        self.meals = mealData.meals
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllMealsCell") as! AllMealsTableViewCell
        cell.mealNameLabel.text = meals[indexPath.row].strMealEdited
        cell.meal = meals[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mealDetailsVC = storyboard?.instantiateViewController(withIdentifier: "MealDetailsViewController") as? MealDetailsViewController
        let selectedMeal: Meal = meals[indexPath.row]
        mealDetailsVC?.mealID = selectedMeal.idMeal
        navigationController?.pushViewController(mealDetailsVC!, animated: true)
    }
}
