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
        URLSession.shared.request(url: URLConstants.allCategoriesURL, expectedEncodingType: Categories.self) { (result: Result<Categories, Error>) in
            switch result {
                case .success(let response):
                    self.categories = response.categories.sorted()
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectCategory" {
            guard let mealListVC = segue.destination as? MealListTableViewController else { return }
            let index: [IndexPath] = self.collectionView.indexPathsForSelectedItems!
            mealListVC.category = self.categories[index[0][1]].strCategory
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CategoryCollectionViewCell else {
            fatalError("Failed dequeuing.")
        }
        
        let category = self.categories[indexPath.row]
        cell.categoryNameLabel.text = category.strCategory
        cell.categoryImageView.image = UIImage(named: category.strCategory.lowercased())
        return cell
    }
}
