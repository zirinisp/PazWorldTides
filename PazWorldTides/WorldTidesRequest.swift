//
//  WorldTidesRequest.swift
//  PazWorldTides
//
//  Created by Pantelis Zirinis on 22/11/2016.
//  Copyright © 2016 paz-labs. All rights reserved.
//

import Foundation
import CoreLocation

public class WorldTidesRequest {
    
    public enum RequestType {
        case heights
        case extremes
        
        var name: String {
            switch self {
            case .heights: return "heights"
            case .extremes: return "extremes"
            }
        }
    }
    
    public struct Parameter {
        var name: String
        var parameter: String
        
        var urlString: String {
            return "\(self.name)=\(self.parameter)"
        }
    }
    public static var BaseUrl: String = "https://www.worldtides.info/api?"

    public let apiKey: String
    public let requestTypes: [RequestType]
    public let coordinate: CLLocationCoordinate2D
    public let maxCalls: Int
    public let length: Int
    
    public var description: String {
        return urlSuffix
    }
    
    public init?(apiKey: String, coordinate: CLLocationCoordinate2D, requestTypes: [RequestType] = [.heights, .extremes], length: Int = 60*60*24*14, maxCalls: Int = 5) {
        guard requestTypes.count != 0 else {
            return nil
        }
        self.apiKey = apiKey
        self.coordinate = coordinate
        self.requestTypes = requestTypes
        self.length = length
        self.maxCalls = maxCalls
    }
    
    var parameters: [Parameter] {
        let lat = Parameter(name: "lat", parameter: "\(self.coordinate.latitude)")
        let lon = Parameter(name: "lon", parameter: "\(self.coordinate.longitude)")
        let maxCalls = Parameter(name: "maxCalls", parameter: "\(self.maxCalls)")
        let length = Parameter(name: "length", parameter: "\(self.length)")
        let key = Parameter(name: "key", parameter: "\(self.apiKey)")
        return [lat, lon, maxCalls, length, key]
    }
    
    public var urlString: String {
        let string = WorldTidesRequest.BaseUrl+self.urlSuffix
        return string
    }
    
    var urlSuffix: String {
        var string = String()
        var first = true
        for type in self.requestTypes {
            if !first {
                string += "&"
            } else  {
              first = false
            }
            string += "\(type.name)"
        }
        for parameter in self.parameters {
            string += "&\(parameter.urlString)"
        }
        return string
        
    }

}
