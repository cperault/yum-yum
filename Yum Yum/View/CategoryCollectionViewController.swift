//
//  CategoryCollectionViewController.swift
//  Yum Yum
//
//  Created by Christopher Perault on 12/9/21.
//

import UIKit

private let reuseIdentifier = "Cell"

class CategoryCollectionViewController: UICollectionViewController {
    var categories: [Category] = []
    var selectedCategory: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        getCategories()
    }
    
    private func getCategories() -> Void {
        let url = URL(string: "https://www.themealdb.com/api/json/v1/1/categories.php")!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            do {
                let decodedResponse = try JSONDecoder().decode(Categories.self, from: data)
                self.categories = decodedResponse.categories.sorted()
            } catch let error {
                print(error)
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        task.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectCategory" {
            guard let mealListVC = segue.destination as? MealListTableViewController else { return }
            let index: [IndexPath] = collectionView.indexPathsForSelectedItems!
            mealListVC.category = categories[index[0][1]].strCategory
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CategoryCollectionViewCell else {
            fatalError("Failed dequeuing.")
        }
        
        let category = categories[indexPath.row]
        cell.categoryNameLabel.text = category.strCategory
        cell.categoryImageView.image = UIImage(named: category.strCategory.lowercased())
        return cell
    }
}
