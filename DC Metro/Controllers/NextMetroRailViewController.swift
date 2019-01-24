//
//  DetailRailStationViewController.swift
//  DC Metro
//
//  Created by Seif Kobrosly on 12/31/18.
//  Copyright © 2018 District Meta Works, LLC. All rights reserved.
//

import UIKit
import PromiseKit
import CodableAlamofire
import Alamofire


class NextMetroRailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let customSessionManager = APIManager.sessionManager
    @IBOutlet var stationLabel:UILabel!
    @IBOutlet var tableView:UITableView!
    var listOfNextTrains:Promise<[Train?]>?
    var currentStation:Station? {
        didSet {
            if let station = currentStation {
                self.listOfNextTrains = self.retriveNextTrainsFromStation(station: station)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.contentInsetAdjustmentBehavior = .never
        if let station = currentStation {
            stationLabel.text = station.name
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let navigationTitleFont = UIFont(name: "Helvetica Neue", size: 18)!
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: navigationTitleFont, NSAttributedStringKey.foregroundColor: UIColor.black]
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let unwrapped = listOfNextTrains?.value?.count {
            return unwrapped
        }
        else
        {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "nextTrainCell", for: indexPath)
        
        if let nextTrain = self.listOfNextTrains?.value?[indexPath.row] {

            cell.textLabel?.text = nextTrain.destinationName
            if let time = nextTrain.min {
                if CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: time)) {
                    if time == "1" {
                        cell.detailTextLabel?.text = String(format: "Arriving in %@ minute", time)
                    }
                    else
                    {
                        cell.detailTextLabel?.text = String(format: "Arriving in %@ minutes", time)
                    }
                }
                else
                {
                    if time == "BRD" {
                        cell.detailTextLabel?.text = String(format: "%@", "Boarding")
                    }
                    else
                    {
                        cell.detailTextLabel?.text = String(format: "%@", "Arriving")
                    }
                }
            }
            
            if let numberOfTrains = nextTrain.car {
                let listCountLabel: UILabel = {
                    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
                    label.text = String(format: "%@ Trains", numberOfTrains)
                    label.textColor = .lightGray
                    label.translatesAutoresizingMaskIntoConstraints = false
                    label.font = UIFont(name: "HelveticaNeue", size: 14)
                    label.textAlignment = .center
                    return label
                }()
                listCountLabel.sizeToFit()
                cell.accessoryView = listCountLabel
            }

            
            var circleColor:UIColor? = nil
            switch nextTrain.line
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
        else
        {
            return cell
        }
    }
    
    func retriveNextTrainsFromStation(station: Station)-> Promise <[Train?]> {
        return Promise { seal in
            let decoder = JSONDecoder()
            let router = RailsRouter(endpoint: .getNextTrains(station: station))
            customSessionManager.request(router)
                .responseDecodableObject(keyPath: "Trains", decoder: decoder) { (response: DataResponse<[Train?]>) in
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
                            self.tableView.reloadData()
                        }
                    case .failure(let error):
                        print(error)
                        seal.reject(NSError(domain: "error retriving list of next trains", code:400, userInfo: nil))
                    }
            }
        }
    }
}
