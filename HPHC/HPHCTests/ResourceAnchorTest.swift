//
//  ResourceAnchorTest.swift
//  HPHCTests
//
//  Created by Surender on 22/03/19.
//  Copyright © 2019 BTC. All rights reserved.
//

import XCTest
@testable import HPHC

class ResourceAnchorTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    func testFetchingResourceList() {
//        let rlist =  DBHandler.resourceListFor(nil, questionKey: nil)
//        XCTAssertEqual(rlist.count, 1)
    }
    
    func testResourcesLifeTimeWhenAnchorDateIsAvailable() {
//        DBHandler.updateResourceLifeTime(nil, questionKey: nil, anchorDateValue: Date())
//        let rlist =  DBHandler.resourceListFor(nil, questionKey: nil)
//        XCTAssertEqual(rlist.count, 0)
    }
    
    func testResourceIsEmpty() {
        let empty = DBHandler.isResourcesEmpty()
        XCTAssert(empty)
    }
    
    func testResourcesLifeTimeWhenAnchorDateIsNotAvailable() {
        
    }
    

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
