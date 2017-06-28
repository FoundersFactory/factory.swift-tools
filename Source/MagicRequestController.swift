//
//  MagicRequestController.swift
//
//  Created by Sam Houghton on 16/05/2017.
//
//

import Foundation

public class MagicRequestController {
    
    let baseUrl: URL
    
    public var headers = [String: String]()
    
    public init(baseUrl url: URL) {
        
        baseUrl = url
    }
    
    public init(urlString: String) {
        
        baseUrl = URL(string: urlString)!
    }
    
    public func get(urlpath path: String, completion: @escaping (Any?, URLResponse?, Error?) -> Swift.Void) {
        
        get(urlpath: path, parameters: nil, completion: completion)
    }
    
    public func get(urlpath path: String, parameters params: [String: String]?, completion: @escaping (Any?, URLResponse?, Error?) -> Swift.Void) {
        
        guard let url = buildRequestUrl(path: path, params: params) else {
            completion(nil, nil, nil)
            return
        }
        
        let defaultSessionConfiguration = URLSessionConfiguration.default
        let defaultSession = URLSession(configuration: defaultSessionConfiguration)
        
        var urlRequest = URLRequest(url: url)
        
        for headerKey in headers.keys {
            
            urlRequest.addValue(headers[headerKey]!, forHTTPHeaderField: headerKey)
        }
        
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
        
        post(urlpath: path, parameters: nil, body: body, completion: completion)
    }
    
    public func post(urlpath path: String, parameters params: [String: String]?, body: [String: Any], completion: @escaping (Any?, URLResponse?, Error?) -> Swift.Void) {
        
        guard
            let data = try? JSONSerialization.data(withJSONObject: body, options: []),
            let url = buildRequestUrl(path: path, params: params) else {
                
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
    
    private func buildRequestUrl(path: String, params: [String: String]?) -> URL? {
        
        var urlString = baseUrl.absoluteString + "/" + path
        
        if let params = params {
            
            if params.keys.count > 0 {
                
                var count = 0
                
                for key in params.keys {
                    
                    guard
                        let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                        let encodedValue = params[key]!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                            continue
                    }
                    
                    if count == 0 {
                        urlString = urlString + "?" + encodedKey + "=" + encodedValue
                    } else {
                        urlString = urlString + "&" + encodedKey + "=" + encodedValue
                    }
                    
                    count += 1
                }
            }
        }
        
        return URL(string: urlString)
    }
}
