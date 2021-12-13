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
        self.tableView.reloadData()
        self.getMeals()
    }
    
    private func getMeals() -> Void {
        if let category = category {
            let url = URL(string: "https://www.themealdb.com/api/json/v1/1/filter.php?c=\(category.lowercased())")!
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data else { return }
                do {
                    let decodedResponse = try JSONDecoder().decode(Meals.self, from: data)
                    self.meals = decodedResponse.meals.sorted()
                } catch let error {
                    print(error)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            task.resume()
        } else {
            print("Failed to receive meals. Current value of category: \(category ?? "nil")")
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
        let mealDetailsVC = storyboard?.instantiateViewController(withIdentifier: "MealDetailsViewController") as? MealDetailsViewController
        let selectedMeal: Meal = meals[indexPath.row]
        mealDetailsVC?.meal = selectedMeal
        navigationController?.pushViewController(mealDetailsVC!, animated: true)
    }
}
