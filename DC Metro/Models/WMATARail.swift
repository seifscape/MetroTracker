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

struct WMATARail: Codable {
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
}

struct Entrance: Codable {
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
}

struct Line: Codable {
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
}

struct Path: Codable {
    let lineCode, stationCode, stationName: String?
    let seqNum, distanceToPrev: Int?
    
    enum CodingKeys: String, CodingKey {
        case lineCode = "LineCode"
        case stationCode = "StationCode"
        case stationName = "StationName"
        case seqNum = "SeqNum"
        case distanceToPrev = "DistanceToPrev"
    }
}

struct Prediction: Codable {
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
}

struct Station: Codable {
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
}

struct Address: Codable {
    let street, city, state, zip: String?
    
    enum CodingKeys: String, CodingKey {
        case street = "Street"
        case city = "City"
        case state = "State"
        case zip = "Zip"
    }
}

struct Stop: Codable {
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
}

struct Train: Codable {
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
