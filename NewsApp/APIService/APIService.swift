//
//  APIService.swift
//  NewsApp
//
//  Created by Victor on 3/31/21.
//

import Foundation

class APIService {
    
    func getNewsData(param: [String: String], completion: @escaping (News?, Error?) -> ()) {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "newsapi.org"
        components.path = "/v2/everything"
        
        components.queryItems = [
            URLQueryItem(name: "apiKey", value: "1d9681ef73434dc896c9543aa303c86d"),
//            URLQueryItem(name: "apiKey", value: "040de4b205224061bc066bc11a174013"),
//            URLQueryItem(name: "apiKey", value: "e4b8f2babceb40b8b1b193ff6e8f8b29"),
//            URLQueryItem(name: "apiKey", value: "4a7bd664e13e4cccad49f14c84792f65"),

            URLQueryItem(name: "domains", value: "bbc.com"),
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "from", value: param["from"]),
            URLQueryItem(name: "to", value: param["to"])
        ]
        
        guard let url = components.url else { return }
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request as URLRequest) { (data, urlResponse, error) in
            if (error != nil) {
                print(String(describing: error))
            }
            
            else {
                if let data = data {
                
                    do {
                    let jsonDecoder = JSONDecoder()
                
                    let newsData = try jsonDecoder.decode(News.self, from: data)
                        if newsData.status != "error" {
                            completion(newsData, error)
                        }
                        else {
                            print("NewsAPI Developer Plan Quote reached")
                        }
                    }
                    catch {
                        print(error)
                    }
                }
            }
        }.resume()
    }
}
