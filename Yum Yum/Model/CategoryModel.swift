//
//  CategoryModel.swift
//  Yum Yum
//
//  Created by Christopher Perault on 12/9/21.
//

import Foundation

struct Category: Codable, Comparable {
    static func < (lhs: Category, rhs: Category) -> Bool {
        lhs.strCategory < rhs.strCategory
    }
    
    let idCategory: String
    let strCategory: String
    let strCategoryThumb: String
    let strCategoryDescription: String
}

struct Categories: Codable {
    let categories: [Category]
}


