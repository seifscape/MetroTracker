//
//  MetroBusStop.swift
//  DC Metro
//
//  Created by Seif Kobrosly on 1/15/19.
//  Copyright © 2019 District Meta Works, LLC. All rights reserved.
//

//    https://stackoverflow.com/questions/46450536/how-to-add-custom-image-to-annotation-via-a-subclass-swift-3-0
import UIKit
import MapKit

class MetroBusStop: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String
    var stop:Stop
    var imageForAnnotationView: UIImage? {
        return UIImage(named: "bus-stop")
    }

    init(title: String, coordinate: CLLocationCoordinate2D, info: String, stop:Stop) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
        self.stop = stop
    }
}
