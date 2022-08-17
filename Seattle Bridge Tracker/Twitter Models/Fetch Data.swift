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
    func fetchTweet(completion: @escaping (Result<Response, Error>) -> Void) {
        do {
            var request = URLRequest(url: URL(string: "https://api.twitter.com/2/users/2768116808/tweets?max_results=100")!,
                                     timeoutInterval: Double.infinity)
            
            request.addValue("Bearer \(Secrets.bearerToken)", forHTTPHeaderField: "Authorization")
            
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                guard error == nil else {
                    completion(.failure(error!))
                    return
                }
                
                if let response = response as? HTTPURLResponse {
                    guard (200 ... 299) ~= response.statusCode else {
                        completion(.failure(HttpError.badResponse))
                        print("❌ Status code is \(response.statusCode)")
                        return
                    }
                    
                    guard let data = data else {
                        completion(.failure(error!))
                        return
                    }
                    
                    do {
                        let jsonDecoder = JSONDecoder()
                        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                        let result = try jsonDecoder.decode(Response.self, from: data)
                        
                        completion(.success(result))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
            task.resume()
        }
    }
}
