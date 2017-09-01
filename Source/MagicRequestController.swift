//
//  MagicRequestController.swift
//
//  Created by Sam Houghton on 30/06/2017.
//  Copyright © 2017 Sam Houghton. All rights reserved.
//

import Foundation

public class MagicRequestController {
    
    let baseUrl: URL
    
    public var headers = [String: String]()
    
    public var sessionDelegate: MagicSessionDelegate?
    
    public init(baseUrl url: URL) {
        
        baseUrl = url
        sessionDelegate = MagicSessionDelegate()
    }
    
    public init(urlString: String) {
        
        baseUrl = URL(string: urlString)!
        sessionDelegate = MagicSessionDelegate()
    }
    
    public func get(urlpath path: String, completion: @escaping (Any?, URLResponse?, Error?) -> Swift.Void) {
        
        get(urlpath: path, parameters: nil, completion: completion)
    }
    
    public func getData(urlpath path: String, parameters params: [String: String]?, completion: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) {
        
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
            
            guard let data = data else {
                
                completion(nil, response, error)
                return
            }
            
            completion(data, response, error)
        }
        
        dataTask.resume()
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
    
    public func postForm(urlPath path: String, body: [String: String], completion: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) {
        
        postForm(urlPath: path, parameters: nil, body: body, completion: completion)
    }
    
    public func postForm(urlPath path: String, parameters params: [String: String]?, body: [String: String], completion: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) {
        
        var formBodyString = ""
        
        for key in body.keys {
            
            if formBodyString == "" {
                formBodyString += "\(key)=\(body[key]!)"
            } else {
                formBodyString += "&\(key)=\(body[key]!)"
            }
        }
        
        postForm(urlPath: path, parameters: params, body: formBodyString, completion: completion)
    }
    
    public func postForm(urlPath path: String, parameters params: [String: String]?, body: String, completion: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) {
        
        guard
            let data = body.data(using: .utf8),
            let url = buildRequestUrl(path: path, params: params) else {
                
                completion(nil, nil, nil)
                return
        }
        
        var request = URLRequest(url: url)
        request.httpBody = data
        request.allHTTPHeaderFields = ["Content-Type":"application/x-www-form-urlencoded"]
        
        for headerKey in headers.keys {
            
            request.addValue(headers[headerKey]!, forHTTPHeaderField: headerKey)
        }
        
        request.httpMethod = "POST"
        
        let defaultSessionConfiguration = URLSessionConfiguration.default
        
        var defaultSession = URLSession(configuration: defaultSessionConfiguration)
        
        if let delegate = self.sessionDelegate {
            defaultSession = URLSession(configuration: defaultSessionConfiguration, delegate: delegate, delegateQueue: nil)
        }
        
        let task = defaultSession.dataTask(with: request) { (data, response, error) in
            guard let data = data else { completion(nil, response, error); return }
            completion(data, response, error)
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

public class MagicSessionDelegate: NSObject, URLSessionTaskDelegate {
    
    var redirectHandler: ((_ resposne: HTTPURLResponse, _ newRequest: URLRequest) -> ())?
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        
        if let handler = redirectHandler {
            handler(response, request)
        }
        
        completionHandler(request)
    }
}
