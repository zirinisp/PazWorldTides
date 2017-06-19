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
import CoreLocation

class PazWorldTidesTests_Mac: XCTestCase {
    
    var worldTides = PazWorldTides(apiKey: "")
    
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
                XCTAssert(tidalSet.coordinate.latitude == tidalSet2?.coordinate.latitude && tidalSet.coordinate.longitude == tidalSet2?.coordinate.longitude)
                XCTAssert(tidalSet.requestCoordinate.latitude == tidalSet2?.requestCoordinate.latitude && tidalSet.requestCoordinate.longitude == tidalSet2?.requestCoordinate.longitude)
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
