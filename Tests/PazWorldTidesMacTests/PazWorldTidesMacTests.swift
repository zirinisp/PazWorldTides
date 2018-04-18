//
//  PazWorldTidesTests_Mac.swift
//  PazWorldTidesTests-Mac
//
//  Created by Pantelis Zirinis on 19/06/2017.
//  Copyright © 2017 paz-labs. All rights reserved.
//

import XCTest
import PazWorldTides
import SwiftyJSON

class PazWorldTidesTests_Mac: XCTestCase {
    
    var worldTides = PazWorldTides(apiKey: "98ec23a8-73bc-4fc8-bff4-e9cb942df6cb")
    
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
        self.worldTides.tidalSetFor(latitude: 52.95, longitude: 4.7, completion: { (result) in
            switch result {
            case .success(let tidalSet):
                print("Got result heights: \(tidalSet.heights?.count ?? 0) extremes: \(tidalSet.extremes?.count ?? 0)")
                let json = tidalSet.json()
                let tidalSet2 = TidalSet(json: json)
                print("Got converted result heights: \(tidalSet2?.heights?.count ?? 0) extremes: \(tidalSet2?.extremes?.count ?? 0)")
                XCTAssert((tidalSet.heights?.count ?? 0) > 0)
                XCTAssert((tidalSet.extremes?.count ?? 0) > 0)
                XCTAssert(tidalSet.heights?.count == tidalSet2?.heights?.count)
                XCTAssert(tidalSet.extremes?.count == tidalSet2?.extremes?.count)
                XCTAssert(tidalSet.atlas == tidalSet2?.atlas)
                XCTAssert(tidalSet.callCount == tidalSet2?.callCount)
                XCTAssert(tidalSet.latitude == tidalSet2?.latitude && tidalSet.longitude == tidalSet2?.longitude)
                XCTAssert(tidalSet.requestLatitude == tidalSet2?.requestLatitude && tidalSet.requestLongitude == tidalSet2?.requestLongitude)
                XCTAssert(tidalSet.copyright == tidalSet2?.copyright)
                
                guard let sortedHeights = tidalSet.heights?.sorted(by: { (a, b) -> Bool in
                    return a.date < b.date
                }) else {
                    return
                }
                guard let sortedHeights2 = tidalSet2?.heights?.sorted(by: { (a, b) -> Bool in
                    return a.date < b.date
                }) else {
                    return
                }
                
                for i in 0..<sortedHeights.count {
                    let height = sortedHeights[i]
                    let height2 = sortedHeights2[i]
                    XCTAssert(height == height2)
                }
                
                guard let sortedExtremes = tidalSet.extremes?.sorted(by: { (a, b) -> Bool in
                    return a.date < b.date
                }) else {
                    return
                }
                guard let sortedExtremes2 = tidalSet2?.extremes?.sorted(by: { (a, b) -> Bool in
                    return a.date < b.date
                }) else {
                    return
                }
                
                for i in 0..<sortedExtremes.count {
                    let extreme = sortedExtremes[i]
                    let extreme2 = sortedExtremes2[i]
                    XCTAssert(extreme == extreme2)
                }
            case .noTideForLocation:
                print("No tide for given location")
                XCTAssert(true)
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

    func testNoTideForLocation() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let tidalExpectation = self.expectation(description: "noTideForLocation")
        self.worldTides.tidalSetFor(latitude: 45.89, longitude: 18.19, completion: { (result) in
            switch result {
            case .success(let tidalSet):
                XCTAssert(false)
            case .noTideForLocation:
                print("No tide for given location")
                XCTAssert(true)
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
