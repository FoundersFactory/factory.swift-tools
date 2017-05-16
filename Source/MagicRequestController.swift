//
//  FactoryRequestController.swift
//
//  Created by Sam Houghton on 16/05/2017.
//
//

import Foundation

public class MagicRequestController {
    
    let baseUrl: URL
    
    public init(baseUrl url: URL) {
        
        baseUrl = url
    }
    
    public init(urlString: String) {
        
        baseUrl = URL(string: urlString)!
    }
    
    public func get(urlpath path: String, completion: @escaping (Any?, URLResponse?, Error?) -> Swift.Void) {
        
        guard let url = URL(string: baseUrl.absoluteString + "/" + path) else {
            completion(nil, nil, nil)
            return
        }
        
        let defaultSessionConfiguration = URLSessionConfiguration.default
        let defaultSession = URLSession(configuration: defaultSessionConfiguration)
        
        let urlRequest = URLRequest(url: url)
        
        let dataTask = defaultSession.dataTask(with: urlRequest) { (data, response, error) in
            
            guard
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
                    
                    completion(nil, response, error)
                    
                    return
            }
            
            completion(json, response, error)
        }
        
        dataTask.resume()
    }
    
    public func post(urlpath path: String, body: [String: Any], completion: @escaping (Any?, URLResponse?, Error?) -> Swift.Void) {
        
        guard
            let data = try? JSONSerialization.data(withJSONObject: body, options: []),
            let url = URL(string: baseUrl.absoluteString + "/" + path)else {
                
                completion(nil, nil, nil)
                return
        }
        
        let defaultSessionConfiguration = URLSessionConfiguration.default
        let defaultSession = URLSession(configuration: defaultSessionConfiguration)
        
        var request = URLRequest(url: url)
        request.httpBody = data
        request.allHTTPHeaderFields = ["Content-Type":"application/json"]
        request.httpMethod = "POST"
        
        let task = defaultSession.dataTask(with: request) { (data, response, error) in
            
            guard
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
                    
                    completion(nil, response, error)
                    
                    return
            }
            
            completion(json, response, error)
        }
        
        task.resume()
    }
}
