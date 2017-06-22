//
//  TidalHeight.swift
//  PazWorldTides
//
//  Created by Pantelis Zirinis on 22/11/2016.
//  Copyright © 2016 paz-labs. All rights reserved.
//

import Foundation
import SwiftyJSON

open class TidalHeight {
    /// Date/Time of this extreme (in seconds since the unix epoch).
    open fileprivate (set) var dt: Int
    /// Date/Time of this extreme (in ISO 8601 standard date and time format, e.g.: 2016-11-22T07:15+0000 ).
    open fileprivate (set) var date: Date
    /// Height (in meters) of the tide.
    open fileprivate (set) var height: Double
    
    public init(dt: Int, date: Date, height: Double) {
        self.dt = dt
        self.date = date
        self.height = height
    }
    
    enum Keys: String {
        case dt = "dt"
        case date = "date"
        case height = "height"
        case type = "type"
    }
    
    open static var dateFormatter: DateFormatter = {
        let dateFormatter: DateFormatter = DateFormatter()
        #if !os(Linux)
            DateFormatter.defaultFormatterBehavior = DateFormatter.Behavior.default
        #endif
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mmZZZ"
        return dateFormatter
    }()
    
    public convenience init?(json: JSON, dateFormatter: DateFormatter? = nil) {
        guard let dateString = json[Keys.date.rawValue].string else {
            return nil
        }
        let formatter = dateFormatter ?? TidalHeight.dateFormatter
        guard let date: Date = formatter.date(from: dateString) else {
            return nil
        }
        guard let height: Double = json[Keys.height.rawValue].doublePaz, let dt: Int = json[Keys.dt.rawValue].int else {
            return nil
        }
        self.init(dt: dt, date: date, height: height)
    }
    
    public func dictionaryValue(dateFormatter: DateFormatter? = nil) -> [String: JSON] {
        var dictionary = [String: JSON]()
        let formatter = dateFormatter ?? TidalHeight.dateFormatter
        dictionary[Keys.date.rawValue] = JSON(formatter.string(from: self.date))
        // We convert to string as there is a problem with MongoKitten and Cheetah and double numbers are not converted correctly
        dictionary[Keys.height.rawValue] = JSON(self.height)
        dictionary[Keys.dt.rawValue] = JSON(self.dt)
        return dictionary
    }
    
    public func json(dateFormatter: DateFormatter? = nil) -> JSON {
        return JSON(self.dictionaryValue())
    }
    
    public class func arrayFrom(heightsJsonArray: [JSON], dateFormatter: DateFormatter? = nil) -> [TidalHeight] {
        var tidalArray = [TidalHeight]()
        for json in heightsJsonArray {
            if let tidalHeight = TidalHeight(json: json, dateFormatter: dateFormatter) {
                tidalArray.append(tidalHeight)
            } else {
                print("error could not create tidal height from dictionary:\n\(json)")
            }
        }
        return tidalArray
    }
}

public func == (lhs: TidalHeight, rhs: TidalHeight) -> Bool {
    return lhs.date == rhs.date && lhs.dt == rhs.dt && lhs.height == rhs.height
}

public func != (lhs: TidalHeight, rhs: TidalHeight) -> Bool {
    return !(lhs == rhs)
}

