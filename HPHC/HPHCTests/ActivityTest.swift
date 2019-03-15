//
//  ActivityTest.swift
//  HPHCTests
//
//  Created by Arun Kumar on 12/03/19.
//  Copyright © 2019 BTC. All rights reserved.
//

import XCTest
@testable import HPHC

class ActivityTest: XCTestCase {

    let activity = Activity()
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
    
//    func testStartDateEndDateForEmpty() {
//        let schedule:[String:Any] = [
//            "startTime": "",
//            "endTime": "",
//            "anchorDate": [
//                "sourceType": "EnrollmentDate",
//                "sourceActivityId": "anct",
//                "sourceKey": "anc",
//                "start": [
//                    "days": 10,
//                    "time": "13:00:00"
//                ],
//                "end": [
//                    "days": -10,
//                    "time": "13:00:00"
//                ]
//            ]
//        ]
//
//        activity.setActivityAvailability(schedule)
//
//        XCTAssertNil(activity.startDate)
//        XCTAssertNil(activity.endDate)
//    }
//
//    func testStartDateEndDateForNonEmpty() {
//        let schedule:[String:Any] = [
//            "startTime": "2019-03-12T00:00:00.000-0700",
//            "endTime": "2019-03-12T00:00:00.000-0700",
//            "anchorDate": [
//                "sourceType": "EnrollmentDate",
//                "sourceActivityId": "anct",
//                "sourceKey": "anc",
//                "start": [
//                    "days": 10,
//                    "time": "13:00:00"
//                ],
//                "end": [
//                    "days": -10,
//                    "time": "13:00:00"
//                ]
//            ]
//        ]
//
//        activity.setActivityAvailability(schedule)
//
//        XCTAssertNotNil(activity.startDate)
//        XCTAssertNotNil(activity.endDate)
//    }
//
//    func testAnchorDateNotAvailable() {
//
//        let schedule:[String:Any] = [
//            "startTime": "2019-03-12T00:00:00.000-0700",
//            "endTime": "2019-03-12T00:00:00.000-0700",
//        ]
//
//        activity.setActivityAvailability(schedule)
//        XCTAssertNil(activity.anchorDate)
//    }
//
//    func testAnchorDateAvailable() {
//        let schedule:[String:Any] = [
//            "startTime": "",
//            "endTime": "",
//            "anchorDate": [
//                "sourceType": "EnrollmentDate",
//                "sourceActivityId": "anct",
//                "sourceKey": "anc",
//                "start": [
//                    "days": 10,
//                    "time": "13:00:00"
//                ],
//                "end": [
//                    "days": -10,
//                    "time": "13:00:00"
//                ]
//            ]
//        ]
//
//        activity.setActivityAvailability(schedule)
//        XCTAssertNotNil(activity.anchorDate)
//    }
//    func testAnchorDateStartDetailsAvailable() {
//        let schedule:[String:Any] = [
//            "startTime": "",
//            "endTime": "",
//            "anchorDate": [
//                "sourceType": "EnrollmentDate",
//                "sourceActivityId": "anct",
//                "sourceKey": "anc",
//                "start": [
//                    "days": 10,
//                    "time": "13:00:00"
//                ],
//                "end": [
//                    "days": -10,
//                    "time": "13:00:00"
//                ]
//            ]
//        ]
//
//        activity.setActivityAvailability(schedule["anchorDate"] as! [String : Any])
//        XCTAssertNotNil(activity.anchorDate?.startTime)
//        XCTAssertEqual(10, activity.anchorDate?.startDays)
//    }
    func testAnchorDateStartDetailsNotAvailable() {
        let schedule:[String:Any] = [
            "startTime": "",
            "endTime": "",
            "anchorDate": [
                "sourceType": "EnrollmentDate",
                "sourceActivityId": "anct",
                "sourceKey": "anc",
                "end": [
                    "days": -10,
                    "time": "13:00:00"
                ]
            ]
        ]
        
        activity.setActivityAvailability(schedule["anchorDate"] as! [String : Any])
        XCTAssertNil(activity.anchorDate?.startTime)
        XCTAssertEqual(0, activity.anchorDate?.startDays)
    }
    func testAnchorDateEndDetailsAvailable() {
        let schedule:[String:Any] = [
            "startTime": "",
            "endTime": "",
            "anchorDate": [
                "sourceType": "EnrollmentDate",
                "sourceActivityId": "anct",
                "sourceKey": "anc",
                "start": [
                    "days": 10,
                    "time": "13:00:00"
                ],
                "end": [
                    "days": -10,
                    "time": "13:00:00"
                ]
            ]
        ]
        
        activity.setActivityAvailability(schedule["anchorDate"] as! [String : Any])
        XCTAssertNotNil(activity.anchorDate?.endTime)
        XCTAssertEqual(-10, activity.anchorDate?.endDays)
    }
    func testAnchorDateEndDetailsNotAvailable() {
        let schedule:[String:Any] = [
            "startTime": "",
            "endTime": "",
            "anchorDate": [
                "sourceType": "EnrollmentDate",
                "sourceActivityId": "anct",
                "sourceKey": "anc",
                "start": [
                    "days": 10,
                    "time": "13:00:00"
                ]
            ]
        ]
        
        activity.setActivityAvailability(schedule["anchorDate"] as! [String : Any])
        XCTAssertNil(activity.anchorDate?.endTime)
        XCTAssertEqual(0, activity.anchorDate?.endDays)
    }
    
    func testActivityLifeTimeForOneTimeFrequency() {
        
        let schedule:[String:Any] = [
            "startTime": "",
            "endTime": "",
            "anchorDate": [
                "sourceType": "EnrollmentDate",
                "sourceActivityId": "anct",
                "sourceKey": "anc",
                "start": [
                    "days": 10,
                    "time": "13:00:00"
                ],
                "end": [
                    "days": -10,
                    "time": "13:00:00"
                ]
            ]
        ]
        
        activity.setActivityAvailability(schedule["anchorDate"] as! [String : Any])
        let date = Date()
        activity.anchorDate?.anchorDateValue = date
        let frequency:Frequency = Frequency.One_Time
        
        let expectedStartDate = date.addingTimeInterval(TimeInterval(60*60*24*10))
        let expectedEndDate = date.addingTimeInterval(TimeInterval(60*60*24*(-10)))
        
        let lifeTime = activity.updateLifeTime(activity.anchorDate!, frequency: frequency)
        
        XCTAssertEqual(expectedStartDate.timeIntervalSinceReferenceDate, lifeTime.0!.timeIntervalSinceReferenceDate)
        XCTAssertEqual(expectedEndDate.timeIntervalSinceReferenceDate, lifeTime.1!.timeIntervalSinceReferenceDate)
    }
    
    func testActivityLifeTimeForDailyFrequency() {
        
        let schedule:[String:Any] = [
            "startTime": "",
            "endTime": "",
            "anchorDate": [
                "sourceType": "EnrollmentDate",
                "sourceActivityId": "anct",
                "sourceKey": "anc",
                "start": [
                    "anchorDays": 10,
                    "time": "13:00:00"
                ],
                "end": [
                    "anchorDays": 0,
                    "repeatInterval":5,
                    "time": "13:00:00"
                ]
            ]
        ]
        
        activity.setActivityAvailability(schedule["anchorDate"] as! [String : Any])
        let date = Date()
        activity.anchorDate?.anchorDateValue = date
        let frequency:Frequency = Frequency.Daily
        
        let expectedStartDate = date.addingTimeInterval(TimeInterval(60*60*24*10))
        let expectedEndDate = expectedStartDate.addingTimeInterval(TimeInterval(60*60*24*(5)))
        
        let lifeTime = activity.updateLifeTime(activity.anchorDate!, frequency: frequency)
        XCTAssertNotNil(lifeTime.0)
        XCTAssertNotNil(lifeTime.1)
        XCTAssertEqual(expectedStartDate.timeIntervalSinceReferenceDate, lifeTime.0?.timeIntervalSinceReferenceDate)
        XCTAssertEqual(expectedEndDate.timeIntervalSinceReferenceDate, lifeTime.1?.timeIntervalSinceReferenceDate)
    }
    
    func testActivityLifeTimeForWeeklyFrequency() {
        
        let schedule:[String:Any] = [
            "startTime": "",
            "endTime": "",
            "anchorDate": [
                "sourceType": "EnrollmentDate",
                "sourceActivityId": "anct",
                "sourceKey": "anc",
                "start": [
                    "anchorDays": 10,
                    "time": "13:00:00"
                ],
                "end": [
                    "anchorDays": 0,
                    "repeatInterval":7,
                    "time": "13:00:00"
                ]
            ]
        ]
        
        activity.setActivityAvailability(schedule["anchorDate"] as! [String : Any])
        let date = Date()
        activity.anchorDate?.anchorDateValue = date
        let frequency:Frequency = Frequency.Weekly
        
        let expectedStartDate = date.addingTimeInterval(TimeInterval(60*60*24*10))
        var expectedEndDate =  expectedStartDate.addingTimeInterval(TimeInterval((7*604800) - 1))
        
        
        let lifeTime = activity.updateLifeTime(activity.anchorDate!, frequency: frequency)
        XCTAssertNotNil(lifeTime.0)
        XCTAssertNotNil(lifeTime.1)
        XCTAssertEqual(expectedStartDate.timeIntervalSinceReferenceDate, lifeTime.0?.timeIntervalSinceReferenceDate)
        XCTAssertEqual(expectedEndDate.timeIntervalSinceReferenceDate, lifeTime.1?.timeIntervalSinceReferenceDate)
    }
    
    func testActivityLifeTimeForWeeklyFrequencyAsValue() {
       let dateValue = "2019-05-25 12:00:00"
        
        let schedule:[String:Any] = [
            "startTime": "",
            "endTime": "",
            "anchorDate": [
                "sourceType": "EnrollmentDate",
                "sourceActivityId": "anct",
                "sourceKey": "anc",
                "start": [
                    "anchorDays": -10,
                    "time": "13:00:00"
                ],
                "end": [
                    "anchorDays": 0,
                    "repeatInterval":2,
                    "time": "13:00:00"
                ]
            ]
        ]
        
        activity.setActivityAvailability(schedule["anchorDate"] as! [String : Any])
        
        let date = Utilities.findDateFromString(dateString: dateValue)
        activity.anchorDate?.anchorDateValue = date
        let frequency:Frequency = Frequency.Weekly
        
        let expectedStartDate = Utilities.findDateFromString(dateString: "2019-05-15 12:00:00")
        let expectedEndDate = Utilities.findDateFromString(dateString: "2019-05-29 11:59:59")

        let lifeTime = activity.updateLifeTime(activity.anchorDate!, frequency: frequency)
        XCTAssertNotNil(lifeTime.0)
        XCTAssertNotNil(lifeTime.1)
        XCTAssertEqual(expectedStartDate?.timeIntervalSinceReferenceDate, lifeTime.0?.timeIntervalSinceReferenceDate)
        XCTAssertEqual(expectedEndDate?.timeIntervalSinceReferenceDate, lifeTime.1?.timeIntervalSinceReferenceDate)
        
    }
    
    func testActivityLifeTimeForMonthlyFrequencyAsValue() {
        let dateValue = "2019-01-31 12:00:00"
        
        let schedule:[String:Any] = [
            "startTime": "",
            "endTime": "",
            "anchorDate": [
                "sourceType": "EnrollmentDate",
                "sourceActivityId": "anct",
                "sourceKey": "anc",
                "start": [
                    "anchorDays": 0,
                    "time": "13:00:00"
                ],
                "end": [
                    "anchorDays": 0,
                    "repeatInterval":1,
                    "time": "13:00:00"
                ]
            ]
        ]
        
        activity.setActivityAvailability(schedule["anchorDate"] as! [String : Any])
        
        let date = Utilities.findDateFromString(dateString: dateValue)
        activity.anchorDate?.anchorDateValue = date
        let frequency:Frequency = Frequency.Monthly
        
        let expectedStartDate = Utilities.findDateFromString(dateString: "2019-01-31 12:00:00")
        let expectedEndDate = Utilities.findDateFromString(dateString: "2019-02-28 11:59:59")
        
        let lifeTime = activity.updateLifeTime(activity.anchorDate!, frequency: frequency)
        XCTAssertNotNil(lifeTime.0)
        XCTAssertNotNil(lifeTime.1)
        XCTAssertEqual(expectedStartDate?.timeIntervalSinceReferenceDate, lifeTime.0?.timeIntervalSinceReferenceDate)
        XCTAssertEqual(expectedEndDate?.timeIntervalSinceReferenceDate, lifeTime.1?.timeIntervalSinceReferenceDate)
        
    }
    
    func testActivityLifeTimeForScheduledFrequencyAsValue() {
        let dateValue = "2019-01-31 12:00:00"
        
        let schedule:[String:Any] = [
            "startTime": "",
            "endTime": "",
            "anchorDate": [
                "sourceType": "EnrollmentDate",
                "sourceActivityId": "anct",
                "sourceKey": "anc",
                "start": [
                    "anchorDays": -10,
                    "time": "13:00:00"
                ],
                "end": [
                    "anchorDays": 10,
                    "repeatInterval":1,
                    "time": "13:00:00"
                ]
            ]
        ]
        
        activity.setActivityAvailability(schedule["anchorDate"] as! [String : Any])
        
        let date = Utilities.findDateFromString(dateString: dateValue)
        activity.anchorDate?.anchorDateValue = date
        let frequency:Frequency = Frequency.Scheduled
        
        let expectedStartDate = Utilities.findDateFromString(dateString: "2019-01-16 12:00:00")
        let expectedEndDate = Utilities.findDateFromString(dateString: "2019-02-10 11:59:59")
        
        let lifeTime = activity.updateLifeTime(activity.anchorDate!, frequency: frequency)
        XCTAssertNotNil(lifeTime.0)
        XCTAssertNotNil(lifeTime.1)
        XCTAssertEqual(expectedStartDate?.timeIntervalSinceReferenceDate, lifeTime.0?.timeIntervalSinceReferenceDate)
        XCTAssertEqual(expectedEndDate?.timeIntervalSinceReferenceDate, lifeTime.1?.timeIntervalSinceReferenceDate)
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
