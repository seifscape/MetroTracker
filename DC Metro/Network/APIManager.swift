//
//  APIManager.swift
//  DC Metro
//
//  Created by Seif Kobrosly on 7/29/18.
//  Copyright © 2018 District Meta Works, LLC. All rights reserved.
//

import Foundation
import Alamofire

final class APIManager {
    var baseURL = K.APIEndpoint.baseURL
    
    static let sharedInstance = APIManager()
    
    static let sessionManager: SessionManager = {
        let sessionManager = Alamofire.SessionManager.default
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil
        sessionManager.adapter = CustomRequestAdapter()
        return sessionManager
    }()
    
    // request adpater to add default http header parameter
    private class CustomRequestAdapter: RequestAdapter {
        public func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
            var urlRequest = urlRequest
            urlRequest.setValue(K.APIParameterKey.kWMATAKey, forHTTPHeaderField: "api_key")
            return urlRequest
        }
    }
    
    internal init() {}
}
