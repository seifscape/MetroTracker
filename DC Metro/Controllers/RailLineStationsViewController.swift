//
//  RailStationsViewController.swift
//  DC Metro
//
//  Created by Seif Kobrosly on 8/25/18.
//  Copyright © 2018 District Meta Works, LLC. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit
import CodableAlamofire

class RailLineStationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView:UITableView!
    let customSessionManager = APIManager.sessionManager
    
    var currentMetroLine:Line?
    var metroPath:Promise<[Path]>?
    var metroLineJsonFile:String = ""
    var listOfMetroStations:Promise<[Station]>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView?.dataSource = self
        self.tableView?.delegate   = self
        if !metroLineJsonFile.isEmpty {
            self.metroPath = self.readJson(fileName: metroLineJsonFile)

        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.listOfMetroStations = self.loadAllMetroStations()
        let navigationTitleFont = UIFont(name: "Helvetica Neue", size: 18)!
        
        if let metroLineColor = currentMetroLine?.lineCode {
            switch metroLineColor {
            case "BL":
                self.navigationController?.navigationBar.barTintColor = metroLineColors.kBL_COLOR
                self.navigationController?.navigationBar.tintColor = UIColor.white
                self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white,
                                                                                NSAttributedStringKey.font: navigationTitleFont]
                self.title = "Blue Line"
            case "GR":
                self.navigationController?.navigationBar.barTintColor = metroLineColors.kGR_COLOR
                self.navigationController?.navigationBar.tintColor = UIColor.white
                self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white,
                                                                                NSAttributedStringKey.font: navigationTitleFont]
                self.title = "Green Line"
            case "OR":
                self.navigationController?.navigationBar.barTintColor = metroLineColors.kOR_COLOR
                self.navigationController?.navigationBar.tintColor = UIColor.white
                self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white,
                                                                                NSAttributedStringKey.font: navigationTitleFont]
                self.title = "Orange Line"
            case "RD":
                self.navigationController?.navigationBar.barTintColor = metroLineColors.kRD_COLOR
                self.navigationController?.navigationBar.tintColor = UIColor.white
                self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white,
                                                                                NSAttributedStringKey.font: navigationTitleFont]
                self.title = "Red Line"
            case "SV":
                self.navigationController?.navigationBar.barTintColor = metroLineColors.kSV_COLOR
                self.navigationController?.navigationBar.tintColor = UIColor.white
                self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white,
                                                                                NSAttributedStringKey.font: navigationTitleFont]
                self.title = "Silver Line"
            case "YL":
                self.navigationController?.navigationBar.barTintColor = metroLineColors.kYL_COLOR
                self.navigationController?.navigationBar.tintColor = UIColor.white
                self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white,
                                                                                NSAttributedStringKey.font: navigationTitleFont]
                self.title = "Yellow Line"
            default:
                self.navigationController?.navigationBar.barTintColor = UIColor.white
                self.navigationController?.navigationBar.tintColor = UIColor.black
                self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black,
                                                                                NSAttributedStringKey.font: navigationTitleFont]
            }
            
        }
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
    }
    
    func locateStationFromPath(path: Path) -> Station? {
        var targetStation:Station?
        
        if let stations = listOfMetroStations?.value {
            if let stationFound = stations.filter({ $0.code == path.stationCode}).first {
                targetStation = stationFound
            }
        }
        return targetStation
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let unwrapped = metroPath?.value?.count {
            return unwrapped
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let metroLine = self.metroPath?.value?[indexPath.row] as Path? {
            let targetStation = self.locateStationFromPath(path: metroLine)
            performSegue(withIdentifier: "showStation", sender: targetStation)
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let data = sender as? Station {
            if segue.identifier == "showStation"{
                if let destinationViewController = segue.destination as? NextMetroRailViewController {
                    destinationViewController.currentStation = data
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "metroPathCell", for: indexPath)
        let metroLine:Path = (self.metroPath?.value?[indexPath.row])!
        cell.textLabel?.text = metroLine.stationName
        cell.imageView?.image       = nil
        
        var circleColor:UIColor? = nil
        switch metroLine.lineCode
        {
        case "BL":
            circleColor = metroLineColors.kBL_COLOR
        case "GR":
            circleColor = metroLineColors.kGR_COLOR
        case "OR":
            circleColor = metroLineColors.kOR_COLOR
        case "RD":
            circleColor = metroLineColors.kRD_COLOR
        case "SV":
            circleColor = metroLineColors.kSV_COLOR
        case "YL":
            circleColor = metroLineColors.kYL_COLOR
        default:
            circleColor = UIColor.clear
        }
        cell.imageView?.image = UIImage.circle(diameter: 20, color: circleColor!)
        
        return cell
    }
    
    private func readJson(fileName:String) -> Promise <[Path]>{
        return Promise { seal in
            let decoder = JSONDecoder()
            do {
                if let file = Bundle.main.url(forResource: fileName, withExtension: "json") {
                    let jsonData = try Data(contentsOf: file)
                    let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
                    if let object = json as? [String: Any] {

                        if ((object["Path"] as? Array<AnyObject>) != nil) {
                            let wMATARail = try? decoder.decode(WMATARail.self, from: jsonData)
                            if let metroPath = wMATARail?.path  {
                                seal.fulfill(metroPath)
                                self.tableView?.reloadData()
                            }
                        }
                    } else if let object = json as? [Any] {
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
    
    private func loadAllMetroStations() -> Promise <[Station]>{
        return Promise { seal in
            do {
                if let file = Bundle.main.url(forResource: "AllRailStations", withExtension: "json") {
                    let data = try Data(contentsOf: file)
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
    
    func retrivePathBetweenStations(fromStation: String, toStation:String)-> Promise <[Station]> {
        return Promise { seal in
            let decoder = JSONDecoder()
            let router = RailsRouter(endpoint: .getPathOfStations(fromStationCode: fromStation, toStationCode: toStation))
            customSessionManager.request(router)
                .responseDecodableObject(keyPath: "Path", decoder: decoder) { (response: DataResponse<[Station]>) in
                    guard response.result.error == nil
                        else {
                            print("error")
                            print(response.result.error!)
                            return
                    }
                    switch response.result {
                    case .success(let results):
                        if response.response?.statusCode == BaseRouter.HTTPStatusCodes.ok.rawValue {
                            seal.fulfill(results)
                            
                        }
                    case .failure(let error):
                        print(error)
                        seal.reject(NSError(domain: "error retriving venues", code:400, userInfo: nil))
                    }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
