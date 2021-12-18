//
//  FileBundleData.swift
//  Yum Yum
//
//  Created by Christopher Perault on 12/17/21.
//

import Foundation

func getFileBundleData<T: Codable>(fileName: String, fileExtension: String, expectedEncodingType: T.Type) -> T {
    var fileData: T?
    do {
        if let fileName = Bundle.main.path(forResource: fileName, ofType: fileExtension) {
            let fileURL: URL = URL(fileURLWithPath: fileName)
            let data = try Data(contentsOf: fileURL)
            let decodedData = try JSONDecoder().decode(expectedEncodingType, from: data)
            fileData = decodedData
        }
    } catch {
        print("Could not read from or find the file, \(fileName).\(fileExtension). Error: \(error)")
    }
    return fileData!
}
