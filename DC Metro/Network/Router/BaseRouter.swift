//
//  BaseRouter.swift
//  DC Metro
//
//  Created by Seif Kobrosly on 7/29/18.
//  Copyright © 2018 District Meta Works, LLC. All rights reserved.
//

import Foundation
import Alamofire

typealias APIParams = [String : Any]?

protocol APIConfiguration {
    var method: Alamofire.HTTPMethod { get }
    var path: String { get }
    var parameters: APIParams { get }
    var baseUrl: String { get }
}

class BaseRouter : URLRequestConvertible, APIConfiguration {
    
    
    enum HTTPStatusCodes : Int {
        case created = 201
        case ok = 200
        case badRequest = 404
        case serverError = 500
    }
    
    init() {}
    
    func getHTTPStatusCode() -> HTTPStatusCodes {
        return .created
    }
    
    var method: Alamofire.HTTPMethod {
        fatalError("[BaseRouter - \(#function)] Must be overridden in subclass")
    }
    
    
    var path: String {
        fatalError("[BaseRouter - \(#function))] Must be overridden in subclass")
    }
    
    var parameters: APIParams { //Alamofire.Parameters {
        fatalError("[BaseRouter - \(#function))] Must be overridden in subclass")
    }
    
    
    var baseUrl: String {
        
        if let stringURL = URL(string: APIManager.sharedInstance.baseURL)?.absoluteString {
            return stringURL
        }
        else
        {
            return K.APIEndpoint.baseURL
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let baseURL = URL(string: self.baseUrl)
        var urlRequest = URLRequest(url: (baseURL?.appendingPathComponent(path))!)
        urlRequest.httpMethod = method.rawValue
        
        if self.method == Alamofire.HTTPMethod.post {
            return try Alamofire.JSONEncoding.default.encode(urlRequest, with: self.parameters)
        } else if self.method == Alamofire.HTTPMethod.put {
            return try Alamofire.URLEncoding.default.encode(urlRequest, with: self.parameters)
        } else {
            return try Alamofire.URLEncoding.queryString.encode(urlRequest, with: self.parameters)
        }
    }
}

extension String: ParameterEncoding {
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }
    
}
