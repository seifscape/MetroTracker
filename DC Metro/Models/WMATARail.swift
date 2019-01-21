// To parse the JSON, add this file to your project and do:
//
//   let wMATARail = try? newJSONDecoder().decode(WMATARail.self, from: jsonData)
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseWMATARail { response in
//     if let wMATARail = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

class WMATARail: Codable {
    let lines: [Line]?
    let stations: [Station]?
    let path: [Path]?
    let trains: [Train]?
    let entrances: [Entrance]?
    let stops: [Stop]?
    let stopName: String?
    let predictions: [Prediction]?
    
    enum CodingKeys: String, CodingKey {
        case lines = "Lines"
        case stations = "Stations"
        case path = "Path"
        case trains = "Trains"
        case entrances = "Entrances"
        case stops = "Stops"
        case stopName = "StopName"
        case predictions = "Predictions"
    }
    
    init(lines: [Line]?, stations: [Station]?, path: [Path]?, trains: [Train]?, entrances: [Entrance]?, stops: [Stop]?, stopName: String?, predictions: [Prediction]?) {
        self.lines = lines
        self.stations = stations
        self.path = path
        self.trains = trains
        self.entrances = entrances
        self.stops = stops
        self.stopName = stopName
        self.predictions = predictions
    }
}

class Entrance: Codable {
    let id, name, stationCode1, stationCode2: String?
    let description: String?
    let lat, lon: Double?
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case name = "Name"
        case stationCode1 = "StationCode1"
        case stationCode2 = "StationCode2"
        case description = "Description"
        case lat = "Lat"
        case lon = "Lon"
    }
    
    init(id: String?, name: String?, stationCode1: String?, stationCode2: String?, description: String?, lat: Double?, lon: Double?) {
        self.id = id
        self.name = name
        self.stationCode1 = stationCode1
        self.stationCode2 = stationCode2
        self.description = description
        self.lat = lat
        self.lon = lon
    }
}

class Line: Codable {
    let lineCode, displayName, startStationCode, endStationCode: String?
    let internalDestination1, internalDestination2: String?
    
    enum CodingKeys: String, CodingKey {
        case lineCode = "LineCode"
        case displayName = "DisplayName"
        case startStationCode = "StartStationCode"
        case endStationCode = "EndStationCode"
        case internalDestination1 = "InternalDestination1"
        case internalDestination2 = "InternalDestination2"
    }
    
    init(lineCode: String?, displayName: String?, startStationCode: String?, endStationCode: String?, internalDestination1: String?, internalDestination2: String?) {
        self.lineCode = lineCode
        self.displayName = displayName
        self.startStationCode = startStationCode
        self.endStationCode = endStationCode
        self.internalDestination1 = internalDestination1
        self.internalDestination2 = internalDestination2
    }
}

class Path: Codable {
    let lineCode, stationCode, stationName: String?
    let seqNum, distanceToPrev: Int?
    
    enum CodingKeys: String, CodingKey {
        case lineCode = "LineCode"
        case stationCode = "StationCode"
        case stationName = "StationName"
        case seqNum = "SeqNum"
        case distanceToPrev = "DistanceToPrev"
    }
    
    init(lineCode: String?, stationCode: String?, stationName: String?, seqNum: Int?, distanceToPrev: Int?) {
        self.lineCode = lineCode
        self.stationCode = stationCode
        self.stationName = stationName
        self.seqNum = seqNum
        self.distanceToPrev = distanceToPrev
    }
}

class Prediction: Codable {
    let routeID, directionText, directionNum: String?
    let minutes: Int?
    let vehicleID, tripID: String?
    
    enum CodingKeys: String, CodingKey {
        case routeID = "RouteID"
        case directionText = "DirectionText"
        case directionNum = "DirectionNum"
        case minutes = "Minutes"
        case vehicleID = "VehicleID"
        case tripID = "TripID"
    }
    
    init(routeID: String?, directionText: String?, directionNum: String?, minutes: Int?, vehicleID: String?, tripID: String?) {
        self.routeID = routeID
        self.directionText = directionText
        self.directionNum = directionNum
        self.minutes = minutes
        self.vehicleID = vehicleID
        self.tripID = tripID
    }
}

class Station: Codable {
    let code, name, stationTogether1, stationTogether2: String?
    let lineCode1: String?
    let lineCode2, lineCode3: String?
    let lineCode4: JSONNull?
    let lat, lon: Double?
    let address: Address?
    
    enum CodingKeys: String, CodingKey {
        case code = "Code"
        case name = "Name"
        case stationTogether1 = "StationTogether1"
        case stationTogether2 = "StationTogether2"
        case lineCode1 = "LineCode1"
        case lineCode2 = "LineCode2"
        case lineCode3 = "LineCode3"
        case lineCode4 = "LineCode4"
        case lat = "Lat"
        case lon = "Lon"
        case address = "Address"
    }
    
    init(code: String?, name: String?, stationTogether1: String?, stationTogether2: String?, lineCode1: String?, lineCode2: String?, lineCode3: String?, lineCode4: JSONNull?, lat: Double?, lon: Double?, address: Address?) {
        self.code = code
        self.name = name
        self.stationTogether1 = stationTogether1
        self.stationTogether2 = stationTogether2
        self.lineCode1 = lineCode1
        self.lineCode2 = lineCode2
        self.lineCode3 = lineCode3
        self.lineCode4 = lineCode4
        self.lat = lat
        self.lon = lon
        self.address = address
    }
}

class Address: Codable {
    let street, city, state, zip: String?
    
    enum CodingKeys: String, CodingKey {
        case street = "Street"
        case city = "City"
        case state = "State"
        case zip = "Zip"
    }
    
    init(street: String?, city: String?, state: String?, zip: String?) {
        self.street = street
        self.city = city
        self.state = state
        self.zip = zip
    }
}

class Stop: Codable {
    let stopID, name: String?
    let lon, lat: Double?
    let routes: [String]?
    
    enum CodingKeys: String, CodingKey {
        case stopID = "StopID"
        case name = "Name"
        case lon = "Lon"
        case lat = "Lat"
        case routes = "Routes"
    }
    
    init(stopID: String?, name: String?, lon: Double?, lat: Double?, routes: [String]?) {
        self.stopID = stopID
        self.name = name
        self.lon = lon
        self.lat = lat
        self.routes = routes
    }
}

class Train: Codable {
    let car, destination, destinationCode, destinationName: String?
    let group, line, locationCode, locationName: String?
    let min: String?
    
    enum CodingKeys: String, CodingKey {
        case car = "Car"
        case destination = "Destination"
        case destinationCode = "DestinationCode"
        case destinationName = "DestinationName"
        case group = "Group"
        case line = "Line"
        case locationCode = "LocationCode"
        case locationName = "LocationName"
        case min = "Min"
    }
    
    init(car: String?, destination: String?, destinationCode: String?, destinationName: String?, group: String?, line: String?, locationCode: String?, locationName: String?, min: String?) {
        self.car = car
        self.destination = destination
        self.destinationCode = destinationCode
        self.destinationName = destinationName
        self.group = group
        self.line = line
        self.locationCode = locationCode
        self.locationName = locationName
        self.min = min
    }
}

// MARK: Encode/decode helpers

class JSONNull: Codable, Hashable {
    
    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }
    
    public var hashValue: Int {
        return 0
    }
    
    public init() {}
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}

// MARK: - Alamofire response handlers

extension DataRequest {
    fileprivate func decodableResponseSerializer<T: Decodable>() -> DataResponseSerializer<T> {
        return DataResponseSerializer { _, response, data, error in
            guard error == nil else { return .failure(error!) }
            
            guard let data = data else {
                return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
            }
            
            return Result { try newJSONDecoder().decode(T.self, from: data) }
        }
    }
    
    @discardableResult
    fileprivate func responseDecodable<T: Decodable>(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: decodableResponseSerializer(), completionHandler: completionHandler)
    }
    
    @discardableResult
    func responseWMATARail(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<WMATARail>) -> Void) -> Self {
        return responseDecodable(queue: queue, completionHandler: completionHandler)
    }
}
