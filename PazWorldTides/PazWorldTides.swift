//
//  PazWorldTides.swift
//  PazWorldTides
//
//  Created by Pantelis Zirinis on 22/11/2016.
//  Copyright © 2016 paz-labs. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON

public typealias TidalSetCompletion = (PazWorldTidesResult<TidalSet>) -> Void

public enum PazWorldTidesResult<T> {
    case success(T)
    case error(error: PazWorldTides.RequestError)
}

public class PazWorldTides {
    
    public enum UpdateNotification {
        case requestSent
        
        var name: Notification.Name {
            switch self {
            case .requestSent: return Notification.Name("PazWorldTides.requestSent")
            }
        }
    }
    
    public enum RequestError: Error {
        case noResult
        case notInitialized
        case urlError
        case serverError(error: Error)
        case jSonError(error: Error?)
        case duplicateRequest
        case unknown
    }
    
    var apiKey: String

    lazy var urlSession: URLSession = {
        return URLSession.shared
    }()
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func tidalSetFor(coordinate: CLLocationCoordinate2D, requestTypes: [WorldTidesRequest.RequestType] = [.heights, .extremes], length: Int = 60*60*24*14, maxCalls: Int = 5, completion: @escaping TidalSetCompletion) {
        guard let request = WorldTidesRequest(apiKey: apiKey, coordinate: coordinate, requestTypes: requestTypes, length: length, maxCalls: maxCalls) else {
            return completion(.error(error: .unknown))
        }
        self.tidalSetFrom(request: request, completion: completion)
    }
    
    func tidalSetFrom(request: WorldTidesRequest, completion: @escaping TidalSetCompletion) {
        guard let url: URL = URL(string: request.urlString)  else {
            return completion(PazWorldTidesResult.error(error: RequestError.urlError))
        }
        
        let task = self.urlSession.dataTask(with: url) { (data, response, error) in
            if let result = data {
                let json = JSON(data: result)
                guard let tidalSet = TidalSet(json: json) else {
                    return completion(.error(error: .jSonError(error: nil)))
                }
                return completion(.success(tidalSet))
            } else {
                if let letError = error {
                    return completion(.error(error: .serverError(error: letError)))
                }
                return completion(.error(error: .unknown))
            }
        }
        task.resume()
    }

    static func dictionaryFromJSonData(_ data: Data) throws -> [String: Any] {
        do {
            if let responseDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: Any] {
                return responseDictionary
            }
        } catch let error as NSError {
            throw PazWorldTides.RequestError.jSonError(error: error)
        }
        throw PazWorldTides.RequestError.jSonError(error: nil)
    }

}

