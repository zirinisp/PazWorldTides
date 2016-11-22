//
//  TideHeights.swift
//  PazWorldTides
//
//  Created by Pantelis Zirinis on 22/11/2016.
//  Copyright © 2016 paz-labs. All rights reserved.
//

import Foundation
import CoreLocation

class TidalSet {
    open fileprivate (set) var status: Int
    open fileprivate (set) var callCount: Int
    open fileprivate (set) var coordinate: CLLocationCoordinate2D
    open fileprivate (set) var requestCoordinate: CLLocationCoordinate2D
    open fileprivate (set) var atlas: String?
    open fileprivate (set) var copyright: String?
    open fileprivate (set) var heights: [TidalHeight]?
    open fileprivate (set) var extremes: [TidalExtreme]?
    open fileprivate (set) var timestamp: Date
}

class TidalHeight {
    /// Date/Time of this extreme (in seconds since the unix epoch).
    open fileprivate (set) var dt: Int
    /// Date/Time of this extreme (in ISO 8601 standard date and time format, e.g.: 2016-11-22T07:15+0000 ).
    open fileprivate (set) var date: Date
    /// Height (in meters) of the tide.
    open fileprivate (set) var height: Double
    
    init(dt: Int, date: Date, height: Double) {
        self.dt = dt
        self.date = Date
        self.height = height
    }
    
    enum Keys: String {
        case dt = "dt"
        case date = "date"
        case height = "height"
        case type = "type"
    }
    
    static var dateFormatter: DateFormatter = {
        let dateFormatter: DateFormatter = DateFormatter()
        #if !os(Linux)
            DateFormatter.defaultFormatterBehavior = DateFormatter.Behavior.default
        #endif
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mmZZZ"
        return dateFormatter
    }()
    
    init?(dictionary: [String: Any]) {
        guard let dateString = dictionary[Keys.date.rawValue] as? String else {
            return nil
        }
        guard let date: Date = TidalHeight.dateFormatter.date(from: dateString) else {
            return nil
        }

    }
}

class TidalExtreme: TidalHeight {
    enum Type {
        case low
        case high
    }

    open fileprivate (set) var type: Type
    
}
