//
//  APIRequest.swift
//  Yum Yum
//
//  Created by Christopher Perault on 12/17/21.
//

import Foundation

extension URLSession {
    enum CustomError: Error {
        case invalidURL
        case invalidData
    }
    
    func request<S: Codable>(url: String, expectedEncodingType: S.Type, completion: @escaping (Result<S, Error>) -> Void) {
        if url == "" {
            completion(.failure(CustomError.invalidURL))
            return
        }
        
        let urlParsed = URLComponents(string: url)
        let request = URLRequest(url: (urlParsed?.url)!)
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            guard let data = data else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(CustomError.invalidData))
                }
                return
            }
            do {
                let result: S = try JSONDecoder().decode(expectedEncodingType, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func requestWithParams<S: Codable>(url: String, parameters: [String: String], expectedEncodingType: S.Type, completion: @escaping (Result<S, Error>) -> Void) {
        if url == "" {
            completion(.failure(CustomError.invalidURL))
            return
        }
        
        var components = URLComponents(string: url)!
        components.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        let request = URLRequest(url: components.url!)
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            guard let data = data else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(CustomError.invalidData))
                }
                return
            }
            do {
                let result: S = try JSONDecoder().decode(expectedEncodingType, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
