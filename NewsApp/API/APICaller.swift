//
//  APICaller.swift
//  NewsApp
//
//  Created by Алина Власенко on 20.03.2023.
//

import Foundation

//API for Articles
final class APICaller {
    //створюємо сінглтон
    static let shared = APICaller()
    
    //передача посилань на API
    struct Constants {
        //посилання на топ статті в США
        static let topHeadlinesURL = URL(string: "https://newsapi.org/v2/top-headlines?country=us&apiKey=6088cdf5cc8744bb8331f36ebfa760c4")
        //посилання до API newsapi - до усих статей з можливістю додавати q=наш_запит_у_пошуковору_рядку
        static let searchUrlString = "https://newsapi.org/v2/everything?sortedBy=popularity&apiKey=6088cdf5cc8744bb8331f36ebfa760c4&q="
    }
    
    //init
    private init() {}
    
    //обробник завершення, що повертає нам результат
    public func getTopArticles(completion: @escaping (Result<[Article], Error>) -> Void) {
        guard let url = Constants.topHeadlinesURL else {
             return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
            }
            else if let data = data {
                do {
                    let result = try JSONDecoder().decode(APIResponse.self, from: data)
                    print("Articles: \(result.articles.count)")
                    completion(.success(result.articles))//повернути статті 
                }
                catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    //обробник завершення, що повертає нам результат після отримання даних з поля пошуку
    public func search(with query: String, completion: @escaping (Result<[Article], Error>) -> Void) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { //щоб обрізати усі пробіли, що запит не є порожнім тобто
            return
        }
        let urlString = Constants.searchUrlString + query // для передачі параметрів пошуку
        //викличемо обробника завершення
        guard let url = URL(string: urlString) else {
             return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
            }
            else if let data = data {
                do {
                    let result = try JSONDecoder().decode(APIResponse.self, from: data)
                    print("Articles: \(result.articles.count)")
                    completion(.success(result.articles))//повернути статті
                }
                catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}
