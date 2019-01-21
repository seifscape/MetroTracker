//
//  MetroStation.swift
//  DC Metro
//
//  Created by Seif Kobrosly on 1/15/19.
//  Copyright © 2019 District Meta Works, LLC. All rights reserved.
//

import UIKit
import MapKit

class MetroStation: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String
    var stationEntrance:Entrance
    var imageForAnnotationView: UIImage? {
        return UIImage(named: "metro-station")
    }

    init(title: String, coordinate: CLLocationCoordinate2D, info: String, stationEntrance:Entrance) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
        self.stationEntrance = stationEntrance
    }
}
