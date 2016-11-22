//
//  PazWorldTidesTests.swift
//  PazWorldTidesTests
//
//  Created by Pantelis Zirinis on 22/11/2016.
//  Copyright © 2016 paz-labs. All rights reserved.
//

import XCTest
@testable import PazWorldTides
import SwiftyJSON
import CoreLocation

class PazWorldTidesTests: XCTestCase {
    
    var worldTides = PazWorldTides(apiKey: "a652eeb9-136c-4732-a8c1-0e592e257b58")
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testHeightsAndExtremes() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let tidalExpectation = self.expectation(description: "tidalSetRequest")
        self.worldTides.tidalSetFor(coordinate: CLLocationCoordinate2D(latitude: 37.82, longitude: 23.77), completion: { (result) in
            switch result {
            case .success(let tidalSet):
                print("Got result heights: \(tidalSet.heights?.count) extremes: \(tidalSet.extremes?.count)")
                XCTAssert((tidalSet.heights?.count ?? 0) > 0)
                XCTAssert((tidalSet.extremes?.count ?? 0) > 0)
            case .error(let error):
                print(error.localizedDescription)
                XCTAssert(false)
            }
            tidalExpectation.fulfill()
        })
        waitForExpectations(timeout: 20.0) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }

    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
