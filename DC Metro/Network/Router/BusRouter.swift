//
//  BusRouter.swift
//  DC Metro
//
//  Created by Seif Kobrosly on 1/4/19.
//  Copyright © 2019 District Meta Works, LLC. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation

enum MetroBusEndpoint
{
    case getBusStops(coordinates:CLLocation, radius:Int)
    case getNextBuses(busStopId:String)

}

class BusRouter: BaseRouter
{
    
    var endpoint: MetroBusEndpoint
    init(endpoint: MetroBusEndpoint)
    {
        self.endpoint = endpoint
    }
    
    override var method: Alamofire.HTTPMethod
    {
        switch endpoint
        {
        case .getBusStops:  return .get
        case .getNextBuses: return .get
        }
    }
    
    override var path: String
    {
        switch endpoint
        {
        case .getBusStops( _, _)     : return "/Bus.svc/json/jStops"
        case .getNextBuses( _)       : return "/NextBusService.svc/json/jPredictions"
        }
    }
    
    override var parameters: APIParams
    {
        switch endpoint
        {
        case .getBusStops(let coordinates, let radius):
            return ["Lat" : coordinates.coordinate.latitude,
                    "Lon": coordinates.coordinate.longitude,
                    "Radius": radius]
        case .getNextBuses(let stopId):
            return ["StopID" : stopId]
        }
    }
}
