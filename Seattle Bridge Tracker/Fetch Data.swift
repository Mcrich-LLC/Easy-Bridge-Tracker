//
//  Fetch Data from Twitter.swift
//  Seattle Bridge Tracker
//
//  Created by Morris Richman on 8/16/22.
//

import Foundation

enum HttpError: Error {
    case badResponse
    case badURL
}

class TwitterFetch {
    func fetchTweet(errorHandler: @escaping (HTTPURLResponse) -> Void, completion: @escaping ([Response]) -> Void) {
        do {
            var request = URLRequest(url: URL(string: "http://mc.mcrich23.com:8080/bridges")!,
                                     timeoutInterval: Double.infinity)
            
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                guard error == nil else {
                    return
                }
                
                if let response = response as? HTTPURLResponse {
                    guard (200 ... 299) ~= response.statusCode else {
                        print("❌ Status code is \(response.statusCode)")
                        errorHandler(response)
                        completion([])
                        return
                    }
                    
                    guard let data = data else {
                        completion([])
                        return
                    }
                    
                    do {
                        let jsonDecoder = JSONDecoder()
                        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                        let result = try jsonDecoder.decode([Response].self, from: data)
                        
                        completion(result)
                    } catch {
                        print("error = \(error)")
                    }
                }
            }
            task.resume()
        }
    }
}
