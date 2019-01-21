//
//  NearByViewController.swift
//  DC Metro
//
//  Created by Seif Kobrosly on 1/6/19.
//  Copyright © 2019 District Meta Works, LLC. All rights reserved.
//

import UIKit
import SPPermission
import CoreLocation
import PromiseKit
import CodableAlamofire
import Alamofire
import MapKit

class NearByViewController: UIViewController {
    
    @IBOutlet var mapView:MKMapView!
    let sessionManager = APIManager.sessionManager
    var nearyByStations:Promise<[Entrance]>?
    var listOfStations:Promise<[Station]>?
    var busStops:Promise<[Stop]>?
    
    
    private var currentLocation: CLLocation? {
        didSet {
            if let unwrappedLocation = currentLocation as CLLocation? {
                self.busStops = self.retriveNearbyBusStopsFromCoordinates(location: unwrappedLocation, radius: 500)
                nearyByStations = self.retriveNearbyStationsFromCoordinates(currentUserLocation: unwrappedLocation, radius: 500)
                let viewRegion = MKCoordinateRegionMakeWithDistance(unwrappedLocation.coordinate, 500, 500)
                mapView.setRegion(viewRegion, animated: true)
            }
        }
    }
    
    private lazy var locationManager: CLLocationManager = {
        // Initialize Location Manager
        let locationManager = CLLocationManager()
        
        // Configure Location Manager
        locationManager.distanceFilter = 1000.0
        locationManager.desiredAccuracy = 1000.0
        
        return locationManager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        self.title = "Metro Tracker"
        // Request Permission
        getLocationPermission()
        self.listOfStations = self.loadAllMetroStations()
    }
    
    func hasAnotherPlatform(code: String) -> Station? {
        var targetStation:Station?
        
        if let stations = listOfStations?.value {
            if let multiPlatform = stations.filter({ $0.stationTogether1! == code }).first {
                targetStation = multiPlatform
            }
        }
        return targetStation
    }
    
    func locateStationFromEntrance(entrance: Entrance) -> Station? {
        var targetStation:Station?
        
        if let stations = listOfStations?.value {
            if let stationFound = stations.filter({ $0.code == entrance.stationCode1 }).first {
                targetStation = stationFound
            }
        }
        return targetStation
    }
    
    private func addMetroEntrances(metroEntrances: [Entrance]) -> Void {
        for metroEntrance in metroEntrances {
            if let stationLatitude = metroEntrance.lat {
                if let stationLongitude = metroEntrance.lon {
                    let coordinate = CLLocationCoordinate2D(latitude: stationLatitude, longitude: stationLongitude)
                    mapView.addAnnotation(MetroStation(title: "", coordinate: coordinate, info: "", stationEntrance: metroEntrance))
                }
            }
        }

    }
    
    private func addBusStops(busStops: [Stop]) ->  Void {
        for busStop in busStops {
            if let metroStopLatitude = busStop.lat {
                if let metroStopLongitutde =  busStop.lon {
                    let coordinate = CLLocationCoordinate2D(latitude: metroStopLatitude, longitude: metroStopLongitutde)
                    mapView.addAnnotation(MetroBusStop(title: "", coordinate: coordinate, info: "", stop: busStop))
                }
            }
        }
    }
    
    private func loadAllMetroStations() -> Promise <[Station]>{
        return Promise { seal in
            do {
                if let file = Bundle.main.url(forResource: "AllRailStations", withExtension: "json") {
                    let data = try Data(contentsOf: file)
                    //https://stackoverflow.com/questions/40210266/crash-convert-dictionary-to-json-string-in-swift-3
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if let object = json as? [String: Any] {
                        if ((object["Stations"] as? [[String: Any]]) != nil) {
                            let wMATARail = try? newJSONDecoder().decode(WMATARail.self, from: data)
                            if let metroStations = wMATARail?.stations  {
                                seal.fulfill(metroStations)
                            }
                        }
                    } else if let object = json as? [Any] {
                        // json is an array
                        print(object)
                    } else {
                        print("JSON is invalid")
                    }
                } else {
                    print("no file")
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    
    func parsePlatformStations(stationCode: String) -> Station? {
        var foundStation:Station?
        
        if let allStations = self.listOfStations?.value as [Station?]? {
            for station in allStations {
                if station?.code == stationCode {
                    foundStation = station
                }
            }
        }
        if let station = foundStation {
            return station
        }
        else {
            return nil
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let data = sender as? Stop {
            if segue.identifier == "showNextBuses"{
                if let destinationViewController = segue.destination as? NextBusesViewController {
                    destinationViewController.busStop = data
                }
            }
        }
        if let data = sender as? Station {
            if segue.identifier == "showNextTrains"{
                if let destinationViewController = segue.destination as? NextMetroRailViewController {
                    destinationViewController.currentStation = data
                }
            }
        }
    }
    
}

extension NearByViewController: CLLocationManagerDelegate, SPPermissionDialogDelegate {
    // MARK: - Location Authorization
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            // Request Location
            manager.requestLocation()
        default: break
        }
    }
    
    // MARK: - Updated Location
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            // Getting Default Lantitude Longitude
            // currentLocation = CLLocation(latitude: Defaults.latitude, longitude: Defaults.longitude)
            return
        }
        // Update Location
        currentLocation = location
        
        // Stop Getting Location
        manager.delegate = nil
        manager.stopUpdatingLocation()
    }
    
    // MARK: - Location Fails
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        if currentLocation == nil {
            // currentLocation = CLLocation(latitude: Defaults.latitude, longitude: Defaults.longitude)
        }
    }
    
    // MARK: - Network Calls
    func retriveNearbyStationsFromCoordinates(currentUserLocation:CLLocation, radius:Int)-> Promise <[Entrance]> {
        return Promise { seal in
            let decoder = JSONDecoder()
            let router = RailsRouter(endpoint: .getStationEntrances(latLong: currentUserLocation, radius:radius))
            sessionManager.request(router)
                .responseDecodableObject(keyPath: "Entrances", decoder: decoder) { (response: DataResponse<[Entrance]>) in
                    guard response.result.error == nil
                        else {
                            print("error")
                            print(response.result.error!)
                            return
                    }
                    switch response.result {
                    case .success(let results):
                        if response.response?.statusCode == BaseRouter.HTTPStatusCodes.ok.rawValue {
                            self.addMetroEntrances(metroEntrances: results)
                            seal.fulfill(results)
                        }
                    case .failure(let error):
                        print(error)
                        seal.reject(NSError(domain: "error retriving stations near by", code:400, userInfo: nil))
                    }
            }
        }
    }
    
    func retriveNearbyBusStopsFromCoordinates(location:CLLocation, radius:Int)-> Promise <[Stop]> {
        return Promise { seal in
            let decoder = JSONDecoder()
            let router = BusRouter(endpoint: .getBusStops(coordinates: location, radius: radius))
            sessionManager.request(router)
                .responseDecodableObject(keyPath: "Stops", decoder: decoder) { (response: DataResponse<[Stop]>) in
                    guard response.result.error == nil
                        else {
                            print("error")
                            print(response.result.error!)
                            return
                    }
                    switch response.result {
                    case .success(let results):
                        if response.response?.statusCode == BaseRouter.HTTPStatusCodes.ok.rawValue {
                            self.addBusStops(busStops: results)
                            seal.fulfill(results)
                            //                            self.tableView.reloadData()
                        }
                    case .failure(let error):
                        print(error)
                        seal.reject(NSError(domain: "error retriving stations near by", code:400, userInfo: nil))
                    }
            }
        }
    }
    
}

extension NearByViewController: MKMapViewDelegate {
    // MARK: - Location Permission Request
    
    private func getLocationPermission() {
        locationManager.delegate = self
        
        guard !SPPermission.isAllow(.locationWhenInUse) else {
            locationManager.requestLocation()
            return
        }
        
        SPPermission.Dialog.request(with: [.locationWhenInUse, .notification], on: self, delegate: self)
    }
    
    func didAllow(permission: SPPermissionType) {
        
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }
        
        if let annotation1 = annotationView?.annotation as? MetroBusStop {
            annotationView?.image = annotation1.imageForAnnotationView
        } else if let annotation2 = annotationView?.annotation as? MetroStation {
            annotationView?.image = annotation2.imageForAnnotationView
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        if let busAnnotation = view.annotation as? MetroBusStop {
            performSegue(withIdentifier: "showNextBuses", sender: busAnnotation.stop)
        } else if let metroAnnotation = view.annotation as? MetroStation {
           let station = self.locateStationFromEntrance(entrance: metroAnnotation.stationEntrance)
            performSegue(withIdentifier: "showNextTrains", sender: station)
        }
    }
}
