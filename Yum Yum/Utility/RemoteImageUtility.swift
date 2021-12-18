//
//  RemoteImageUtility.swift
//  Yum Yum
//
//  Created by Christopher Perault on 12/17/21.
//

import UIKit

func getRemoteImage(mealImageURL: String) -> UIImage? {
    guard let imageURL: URL = URL(string: mealImageURL) else {
        return UIImage(named: "kitchen")
    }
    guard let imageData: Data = try? Data(contentsOf: imageURL) else {
        return UIImage(named: "kitchen")
    }
    return UIImage(data: imageData)
}
