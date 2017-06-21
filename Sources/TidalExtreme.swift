//
//  TidalExtreme.swift
//  PazWorldTides
//
//  Created by Pantelis Zirinis on 22/11/2016.
//  Copyright © 2016 paz-labs. All rights reserved.
//

import Foundation
import SwiftyJSON

open class TidalExtreme: TidalHeight {
    public enum TidalType: String {
        case low
        case high
        
        init?(string: String) {
            let lowercase = string.lowercased()
            switch lowercase {
            case "low":
                self = .low
            case "high":
                self = .high
            default:
                return nil
            }
        }
    }
    
    open fileprivate (set) var type: TidalType
    
    public init(dt: Int, date: Date, height: Double, type: TidalType) {
        self.type = type
        super.init(dt: dt, date: date, height: height)
    }
    
    public convenience init?(json: JSON) {
        guard let typeString = json[Keys.type.rawValue].string, let type = TidalType(string: typeString) else {
            return nil
        }
        guard let dateString = json[Keys.date.rawValue].string else {
            return nil
        }
        guard let date: Date = TidalHeight.dateFormatter.date(from: dateString) else {
            return nil
        }
        guard let height: Double = json[Keys.height.rawValue].double, let dt: Int = json[Keys.dt.rawValue].int else {
            return nil
        }
        self.init(dt: dt, date: date, height: height, type: type)
    }

    public override func dictionaryValue(dateFormatter: DateFormatter? = nil) -> [String: JSON] {
        var dictionary = super.dictionaryValue()
        dictionary[Keys.type.rawValue] = JSON(self.type.rawValue)
        return dictionary
    }

    public class func arrayFrom(extremesJsonArray: [JSON]) -> [TidalExtreme] {
        var tidalArray = [TidalExtreme]()
        for json in extremesJsonArray {
            if let tidalHeight = TidalExtreme(json: json) {
                tidalArray.append(tidalHeight)
            } else {
                print("error could not create tidal extreme from dictionary:\n\(json)")
            }
        }
        return tidalArray
    }
    
}

public func == (lhs: TidalExtreme, rhs: TidalExtreme) -> Bool {
    return lhs.date == rhs.date && lhs.dt == rhs.dt && lhs.height == rhs.height && lhs.type == rhs.type
}

public func != (lhs: TidalExtreme, rhs: TidalExtreme) -> Bool {
    return !(lhs == rhs)
}
