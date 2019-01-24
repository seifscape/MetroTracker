//
//  Helper.swift
//  DC Metro
//
//  Created by Seif Kobrosly on 1/22/19.
//  Copyright © 2019 District Meta Works, LLC. All rights reserved.
//

import Foundation
import Alamofire

class Helper
{
    // MARK - Network Calls
    class func validateWMATAKey(apiKey: String) -> Bool
    {
        let isValid:Bool = false
        Alamofire.request("http://jsonplaceholder.typicode.com/posts").responseData(completionHandler: {
            response in
            guard response.result.isSuccess else {
                print("Request error: \(response.result.error)")
                return
            }
            
            if let data = response.data
            {
                do {
                    let json = try JSON(data: data)
                    print(json)
                }
                catch {
                    print("JSON error!")
                }
            }
        })
        
        
        return isValid
    }
}
