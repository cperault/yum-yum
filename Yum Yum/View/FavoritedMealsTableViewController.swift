//
//  FavoritedMealsTableViewController.swift
//  Yum Yum
//
//  Created by Christopher Perault on 12/15/21.
//

import UIKit
import CoreData

class FavoritedMealsTableViewController: UITableViewController {
    var favoritedMeals: [FavoritedMeals] = []
    var selectedMeal: MealDetails?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getFavoritedMeals()
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
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favoritedMeals.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoritedMealCell") as! FavoritedMealsTableViewCell
        let favorite = favoritedMeals[indexPath.row]
        cell.favoritedMealName.text = favorite.mealName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMealID = favoritedMeals[indexPath.row].mealID
        let mealDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "MealDetailsViewController") as? MealDetailsViewController
        mealDetailsVC?.mealID = selectedMealID
        self.navigationController?.pushViewController(mealDetailsVC!, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            self.unfavoriteMeal(mealID: favoritedMeals[indexPath.row].mealID!, indexPath: indexPath)
        }
    }
    
    func unfavoriteMeal(mealID: String, indexPath: IndexPath) -> Void {
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
            self.favoritedMeals.remove(at: indexPath.row)
            
            do {
                try managedContext.save()
            } catch {
                print("Could not save after deletion")
            }
            
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
