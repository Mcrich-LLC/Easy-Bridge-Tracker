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
            var request = URLRequest(url: URL(string: "https://api.twitter.com/2/users/2768116808/tweets")!,
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
                        print("json keyDecodingStrategy = \(jsonDecoder.keyDecodingStrategy)")
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
    
    private func createURL() throws -> URL {
//        let apiURL = "https://api.twitter.com/2/tweets"
//        let expansions = "author_id&user.fields=profile_image_url,verified"
//        let tweetFields = "created_at"
//        
//        guard url.contains("twitter.com") else {
//            throw HttpError.badURL
//        }
//        
//         let id = url.components(separatedBy: "/").last!.components(separatedBy: "?")[0]
        
        guard let completeURL = URL(string: /*"\(apiURL)?ids=\(id)&expansions=\(expansions)&tweet.fields=\(tweetFields)"*/"https://api.twitter.com/2/users/:id/tweets?id=2768116808") else {
            throw HttpError.badURL
        }
        return completeURL
    }
}
