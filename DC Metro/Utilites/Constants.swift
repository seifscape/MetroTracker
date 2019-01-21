//
//  Constants.swift
//  DC Metro
//
//  Created by Seif Kobrosly on 7/29/18.
//  Copyright © 2018 District Meta Works, LLC. All rights reserved.
//

import Foundation
import UIKit

struct K {
    struct APIEndpoint {
        static let baseURL = "https://api.wmata.com"
    }
    
    struct APIParameterKey {
        static let kWMATAKey = "5567991d9d3d4faf8003a5118a5bfa25"
    }
}

struct metroLineColors {
    static let kBL_COLOR:UIColor = UIColor(red:0.07, green:0.49, blue:0.75, alpha:1.00)
    static let kGR_COLOR:UIColor = UIColor(red:0.10, green:0.67, blue:0.36, alpha:1.00)
    static let kOR_COLOR:UIColor = UIColor(red:0.96, green:0.59, blue:0.25, alpha:1.00)
    static let kRD_COLOR:UIColor = UIColor(red:0.88, green:0.21, blue:0.29, alpha:1.00)
    static let kSV_COLOR:UIColor = UIColor(red:0.64, green:0.65, blue:0.64, alpha:1.00)
    static let kYL_COLOR:UIColor = UIColor(red:1.00, green:0.82, blue:0.24, alpha:1.00)

}

enum HTTPHeaderField: String {
    case authentication = "Authorization"
    case contentType = "Content-Type"
    case acceptType = "Accept"
    case acceptEncoding = "Accept-Encoding"
}

enum ContentType: String {
    case json = "application/json"
}
