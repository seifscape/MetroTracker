//
//  NextBusesViewController.swift
//  DC Metro
//
//  Created by Seif Kobrosly on 1/20/19.
//  Copyright © 2019 District Meta Works, LLC. All rights reserved.
//

import UIKit
import PromiseKit
import CodableAlamofire
import Alamofire

class NextBusesViewController: UIViewController {
    
    let customSessionManager = APIManager.sessionManager
    @IBOutlet var busStopLabel:UILabel!
    @IBOutlet var tableView:UITableView!
    var listOfNextBuses:Promise<[Prediction?]>?
    var busStop:Stop?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Next Buses"
        self.tableView.dataSource = self
        self.tableView.delegate = self
        if let stop = busStop {
            self.busStopLabel.text = stop.name
            if let id = stop.stopID {
                listOfNextBuses = self.retriveNextBuses(stopId: id)
            }
        }
    
    }
    
    func retriveNextBuses(stopId: String)-> Promise <[Prediction?]> {
        return Promise { seal in
            let decoder = JSONDecoder()
            let router = BusRouter(endpoint: .getNextBuses(busStopId: stopId))
            customSessionManager.request(router)
                .responseDecodableObject(keyPath: "Predictions", decoder: decoder) { (response: DataResponse<[Prediction?]>) in
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
                        seal.reject(NSError(domain: "error retriving list of next buses prediction", code:400, userInfo: nil))
                    }
            }
        }
    }
}

extension NextBusesViewController:UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let unwrapped = listOfNextBuses?.value?.count {
            return unwrapped
        }
        else
        {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "nextBusCell", for: indexPath)
        
        if let nextBus = self.listOfNextBuses?.value?[indexPath.row] {
            
            cell.textLabel?.text = nextBus.directionText
            if let time = nextBus.minutes {
                if time == 1 {
                    cell.detailTextLabel?.text = String(format: "Arriving in %i minute", time)
                }
                else
                {
                    cell.detailTextLabel?.text = String(format: "Arriving in %i minutes", time)
                }
            }
            return cell
            
        }
        else
        {
            return cell
        }
    }
}
