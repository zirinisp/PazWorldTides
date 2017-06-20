//
//  TideHeights.swift
//  PazWorldTides
//
//  Created by Pantelis Zirinis on 22/11/2016.
//  Copyright © 2016 paz-labs. All rights reserved.
//

import Foundation
#if os(iOS)
import CoreLocation
#endif
import SwiftyJSON

open class TidalSet {
    open fileprivate (set) var status: Int
    open fileprivate (set) var callCount: Int
    open fileprivate (set) var latitude: Double
    open fileprivate (set) var longitude: Double
    open fileprivate (set) var requestLatitude: Double
    open fileprivate (set) var requestLongitude: Double
    open fileprivate (set) var atlas: String?
    open fileprivate (set) var copyright: String?
    open fileprivate (set) var heights: [TidalHeight]?
    open fileprivate (set) var extremes: [TidalExtreme]?
    open fileprivate (set) var timestamp: Date

    public enum Keys: String {
        case status = "status"
        case callCount = "callCount"
        case responseLat = "responseLat"
        case responseLon = "responseLon"
        case requestLat = "requestLat"
        case requestLon = "requestLon"
        case atlas = "atlas"
        case copyright = "copyright"
        case heights = "heights"
        case extremes = "extremes"
        case timestamp = "timestamp"
    }
    
    #if os(iOS)
    public convenience init(status: Int, callCount: Int, coordinate: CLLocationCoordinate2D, requestCoordinate: CLLocationCoordinate2D, atlas: String?, copyright: String?, heights: [TidalHeight]?, extremes: [TidalExtreme]?, timestamp: Date = Date()) {
        self.init(status: status, callCount: callCount, latitude: coordinate.latitude, longitude: coordinate.longitude, requestLatitude: requestCoordinate.latitude, requestLongitude: requestCoordinate.longitude, atlas: atlas, copyright: copyright, heights: heights, extremes: extremes, timestamp: timestamp)
    }
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
    public var requestCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.requestLatitude, longitude: self.requestLongitude)
    }
    #endif

    public init(status: Int, callCount: Int, latitude: Double, longitude: Double, requestLatitude: Double, requestLongitude: Double, atlas: String?, copyright: String?, heights: [TidalHeight]?, extremes: [TidalExtreme]?, timestamp: Date = Date()) {
        self.status = status
        self.callCount = callCount
        self.latitude = latitude
        self.longitude = longitude
        self.requestLatitude = requestLatitude
        self.requestLongitude = requestLongitude
        self.atlas = atlas
        self.copyright = copyright
        self.heights = heights
        self.extremes = extremes
        self.timestamp = timestamp
    }

    public convenience init?(json: JSON) {
        guard let status = json[Keys.status.rawValue].int, let callCount = json[Keys.callCount.rawValue].int else {
            return nil
        }
        guard let requestLon = json[Keys.requestLon.rawValue].doublePaz, let requestLat = json[Keys.requestLat.rawValue].doublePaz  else {
            return nil
        }
        guard let lon = json[Keys.responseLon.rawValue].doublePaz, let lat = json[Keys.responseLat.rawValue].doublePaz  else {
            return nil
        }
        let atlas = json[Keys.atlas.rawValue].string
        let copyright = json[Keys.copyright.rawValue].string
        var heightsArray: [TidalHeight]?
        if let heightsJsonArray = json[Keys.heights.rawValue].array {
            heightsArray = TidalHeight.arrayFrom(heightsJsonArray: heightsJsonArray)
        }
        var extremesArray: [TidalExtreme]?
        if let extremesJsonArray = json[Keys.extremes.rawValue].array {
            extremesArray = TidalExtreme.arrayFrom(extremesJsonArray: extremesJsonArray)
        }
        self.init(status: status, callCount: callCount, latitude: lat, longitude: lon, requestLatitude: requestLat, requestLongitude: requestLon, atlas: atlas, copyright: copyright, heights: heightsArray, extremes: extremesArray)
    }
    
    public lazy var startDate: Date? = {
        guard let heights = self.heights, heights.count != 0 else {
            return nil
        }
        var startDate: Date = heights[0].date
        for height in heights {
            if startDate.isAfter(height.date) {
                startDate = height.date
            }
        }
        return startDate
    }()
    
    public lazy var endDate: Date? = {
        guard let heights = self.heights, heights.count != 0 else {
            return nil
        }
        var startDate: Date = heights[0].date
        for height in heights {
            if startDate.isBefore(height.date) {
                startDate = height.date
            }
        }
        return startDate
    }()
    
    public func dictionaryValue() -> [String: JSON] {
        var dictionary = [String: JSON]()
        dictionary[Keys.status.rawValue] = JSON(self.status)
        dictionary[Keys.callCount.rawValue] = JSON(self.callCount)
        dictionary[Keys.requestLon.rawValue] = JSON(self.requestLongitude)
        dictionary[Keys.requestLat.rawValue] = JSON(self.requestLatitude)
        dictionary[Keys.responseLon.rawValue] = JSON(self.longitude)
        dictionary[Keys.responseLat.rawValue] = JSON(self.latitude)
        if let copyright = self.copyright {
            dictionary[Keys.copyright.rawValue] = JSON(copyright)
        }
        if let atlas = self.atlas {
            dictionary[Keys.atlas.rawValue] = JSON(atlas)
        }
        
        if let heights = self.heights {
            var array = [JSON]()
            for height in heights {
                array.append(height.json())
            }
            dictionary[Keys.heights.rawValue] = JSON(array)
        }
        if let extremes = self.extremes {
            var array = [JSON]()
            for extreme in extremes {
                array.append(extreme.json())
            }
            dictionary[Keys.extremes.rawValue] = JSON(array)
        }
        return dictionary
    }
    
    public func json() -> JSON {
        return JSON(self.dictionaryValue())
    }
    
}

extension JSON {
    var doublePaz: Double? {
        if let double = self.double {
            return double
        }
        if let doubleString = self.string {
            return Double(doubleString)
        }
        return nil
    }
}

extension Date {
    internal func isAfter(_ date: Date) -> Bool{
        return (self.compare(date as Date) == ComparisonResult.orderedDescending)
    }
    
    internal func isBefore(_ date: Date) -> Bool{
        return (self.compare(date as Date) == ComparisonResult.orderedAscending)
    }
    
}
