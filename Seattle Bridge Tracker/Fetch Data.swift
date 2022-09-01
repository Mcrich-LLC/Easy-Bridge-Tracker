//
//  Fetch Data from Twitter.swift
//  Seattle Bridge Tracker
//
//  Created by Morris Richman on 8/16/22.
//

import Foundation
import HTTPStatusCodes

enum HttpError: Error {
    case badResponse
    case badURL
}

class TwitterFetch {
    func fetchTweet(errorHandler: @escaping (HTTPStatusCode) -> Void, completion: @escaping ([Response]) -> Void) {
        do {
            var request = URLRequest(url: URL(string: "http://mc.mcrich23.com:8080/bridges")!,
                                     timeoutInterval: 5.0)
            
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {
                    if error?.localizedDescription.range(of: "Could not connect to the server.") != nil {
                        print("Could not connect to the server!")
                        errorHandler(.networkConnectTimeoutError)
                        completion([])
                    } else /*if error?.localizedDescription.range(of: "A server with the specified hostname could not be found.") != nil*/ {
                        print("A server with the specified hostname could not be found.")
                        errorHandler(.notFound)
                        completion([])
                    }
                    
                    return
                }
                
                if let response = response as? HTTPURLResponse {
                    guard (200 ... 299) ~= response.statusCode else {
                        print("❌ Status code is \(response.statusCode)")
                        errorHandler(HTTPStatusCode(rawValue: response.statusCode) ?? .notFound)
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
                        if Utilities.isFastlaneRunning {
                            if let bundlePath = Bundle.main.url(forResource: "DummyPromo", withExtension: "json") {
                                let result = try jsonDecoder.decode([Response].self, from: Data(contentsOf: bundlePath))
                                
                                completion(result)
                            } else {
                                let result = try jsonDecoder.decode([Response].self, from: data)
                                
                                completion(result)
                            }
                        } else {
                            let result = try jsonDecoder.decode([Response].self, from: data)
                            
                            completion(result)
                        }
                    } catch {
                        print("error = \(error)")
                    }
                }
            }
            task.resume()
        }
    }
}
