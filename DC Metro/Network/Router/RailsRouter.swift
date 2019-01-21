//
//  RailsRouter.swift
//  DC Metro
//
//  Created by Seif Kobrosly on 7/29/18.
//  Copyright © 2018 District Meta Works, LLC. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation

enum MetroRailsEndpoint
{
    case getRails
    case getStations(lineCode:String)
    case getPathOfStations(fromStationCode:String, toStationCode:String)
    case getNextTrains(station: Station)
    case getStationEntrances(latLong:CLLocation, radius:Int)
}

class RailsRouter: BaseRouter
{
    
    var endpoint: MetroRailsEndpoint
    init(endpoint: MetroRailsEndpoint)
    {
        self.endpoint = endpoint
    }
    
    override var method: Alamofire.HTTPMethod
    {
        switch endpoint
        {
        case .getRails:                 return .get
        case .getStations:              return .get
        case .getPathOfStations:        return .get
        case .getNextTrains:            return .get
        case .getStationEntrances:      return .get
        }
    }
    
    override var path: String
    {
        switch endpoint
        {
        case .getRails                          : return "/Rail.svc/json/jLines"
        case .getStations( _)                   : return "/Rail.svc/json/jStations"
        case .getPathOfStations( _, _)          : return "/Rail.svc/json/jPath"
        case .getNextTrains(let station):
            var urlString = String()
            if let code = station.code {
                if let otherPlatform = station.stationTogether1 {
                    let stationCodeString = "\(code),\(otherPlatform)"
                    urlString = String(format: "/StationPrediction.svc/json/GetPrediction/%@", stationCodeString)
                }
                else
                {
                    urlString = String(format: "/StationPrediction.svc/json/GetPrediction/%@", code)
                }
            }
           return urlString
        case .getStationEntrances( _, _): return "/Rail.svc/json/jStationEntrances"
        }
    }
    
    override var parameters: APIParams
    {
        switch endpoint
        {
        case .getRails: return nil
        case .getStations(let lineCode):
            return ["LineCode": lineCode]
        case .getPathOfStations(let fromStationCode, let toStationCode):
            return ["FromStationCode": fromStationCode,
                    "ToStationCode"  : toStationCode]
        case .getNextTrains(_): return nil
        case .getStationEntrances(let latLong, let radius):
            return ["Lat" : latLong.coordinate.latitude,
                    "Lon": latLong.coordinate.longitude,
                    "Radius": radius]
        }
    }
}
