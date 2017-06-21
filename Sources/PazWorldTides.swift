//
//  PazWorldTides.swift
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

public typealias TidalSetCompletion = (PazWorldTidesResult<TidalSet>) -> Void

public enum PazWorldTidesResult<T> {
    case success(T)
    case error(error: PazWorldTides.RequestError)
}

open class PazWorldTides {
    
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
    
    public init(apiKey: String) {
        self.apiKey = apiKey
    }
    #if os(iOS)
    public func tidalSetFor(coordinate: CLLocationCoordinate2D, requestTypes: [WorldTidesRequest.RequestType] = [.heights, .extremes], length: Int = 60*60*24*14, maxCalls: Int = 5, completion: @escaping TidalSetCompletion) {
        guard let request = WorldTidesRequest(apiKey: apiKey, coordinate: coordinate, requestTypes: requestTypes, length: length, maxCalls: maxCalls) else {
            return completion(.error(error: .unknown))
        }
        self.tidalSetFrom(request: request, completion: completion)
    }
    #else
    public func tidalSetFor(latitude: Double, longitude: Double, requestTypes: [WorldTidesRequest.RequestType] = [.heights, .extremes], length: Int = 60*60*24*14, maxCalls: Int = 5, completion: @escaping TidalSetCompletion) {
        guard let request = WorldTidesRequest(apiKey: apiKey, latitude: latitude, longitude: longitude, requestTypes: requestTypes, length: length, maxCalls: maxCalls) else {
            return completion(.error(error: .unknown))
        }
        self.tidalSetFrom(request: request, completion: completion)
    }
    #endif
    
    public func tidalSetFrom(request: WorldTidesRequest, completion: @escaping TidalSetCompletion) {
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
}
