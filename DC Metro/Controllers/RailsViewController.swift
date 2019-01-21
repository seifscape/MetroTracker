//
//  FirstViewController.swift
//  DC Metro
//
//  Created by Seif Kobrosly on 7/29/18.
//  Copyright © 2018 District Meta Works, LLC. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit

class RailsViewController: UIViewController {
    
    @IBOutlet var tableView:UITableView?
    var numberOfLines: Promise<[Line]>?
    let customSessionManager = APIManager.sessionManager
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView?.dataSource = self
        self.tableView?.delegate   = self
        numberOfLines = self.readJson(fileName: "RailLines")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.title = "Rails"
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        let navigationTitleFont = UIFont(name: "Helvetica Neue", size: 18)!
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: navigationTitleFont, NSAttributedStringKey.foregroundColor: UIColor.black]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let data = sender as? Line {
            if segue.identifier == "listOfStationsSegue"{
                if let destinationViewController = segue.destination as? RailLineStationsViewController {
                    destinationViewController.currentMetroLine = data
                }
            }
        }
    }
    
    func retriveLines()-> Promise <[Station]> {
        return Promise { seal in
            let decoder = JSONDecoder()
            let router = RailsRouter(endpoint: .getRails)
            customSessionManager.request(router)
                .responseDecodableObject(keyPath: "Path", decoder: decoder) { (response: DataResponse<[Station]>) in
                    guard response.result.error == nil
                        else {
                            print("error")
                            print(response.result.error!)
                            return
                    }
                    switch response.result {
                    case .success(let jsonResponse):
                        if response.response?.statusCode == BaseRouter.HTTPStatusCodes.ok.rawValue {
                            seal.fulfill(jsonResponse)
                            self.tableView?.reloadData()
                        }
                    case .failure(let error):
                        print(error)
                        seal.reject(NSError(domain: "error retriving metro lines", code:400, userInfo: nil))
                    }
            }
        }
    }
    
    private func readJson(fileName:String) -> Promise <[Line]>{
        return Promise { seal in
            let decoder = JSONDecoder()
            do {
                if let file = Bundle.main.url(forResource: fileName, withExtension: "json") {
                    let jsonData = try Data(contentsOf: file)
                    let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
                    if let object = json as? [String: Any] {                         // json is a dictionary
                        if (object["Lines"] as? Array<AnyObject>) != nil {
                            let wMATARail = try? decoder.decode(WMATARail.self, from: jsonData)
                            if let stations = wMATARail?.lines {
                                seal.fulfill(stations)
                                self.tableView?.reloadData()
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

    func retriveStations(lineCodeString: String)-> Promise <[Station]> {
        return Promise { seal in
            let decoder = JSONDecoder()
            let router = RailsRouter(endpoint: .getStations(lineCode: lineCodeString))
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
}

extension RailsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let unwrapped = numberOfLines?.value?.count {
            return unwrapped
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "metroLineCell", for: indexPath)
        
        let metroLine = self.numberOfLines?.value![indexPath.row] as Line?
        cell.textLabel?.text = metroLine?.displayName
        cell.detailTextLabel?.text = metroLine?.lineCode
        
        var circleColor:UIColor? = nil
        
        switch metroLine?.lineCode {
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
        cell.imageView?.image = UIImage.circle(diameter: 35, color: circleColor!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView.cellForRow(at: indexPath) != nil else {
            return
        }
        
        let metroLine:Line = (self.numberOfLines?.value![indexPath.row])!
        var jsonFileName:String = String()
        
        switch metroLine.lineCode {
        case "BL":
            jsonFileName = "BlueLineStations"
        case "GR":
            jsonFileName = "GreenLineStations"
        case "OR":
            jsonFileName = "OrangeLineStations"
        case "RD":
            jsonFileName = "RedLineStations"
        case "SV":
            jsonFileName = "SilverLineStations"
        case "YL":
            jsonFileName = "YellowLineStations"
        default:
            return
            
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "listOfStationsViewController") as? RailLineStationsViewController {
            controller.currentMetroLine = metroLine
            controller.currentMetroLine = metroLine
            controller.metroLineJsonFile = jsonFileName
            self.navigationController?.pushViewController(controller, animated: true)
        }
        DispatchQueue.main.async {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

extension UIImage {
    class func circle(diameter: CGFloat, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.saveGState()
        
        let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        ctx.setFillColor(color.cgColor)
        ctx.fillEllipse(in: rect)
        
        ctx.restoreGState()
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return img
    }
}
