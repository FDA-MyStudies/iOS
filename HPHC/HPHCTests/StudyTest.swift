//
//  StudyTest.swift
//  HPHCTests
//
//  Created by Tushar on 2/20/19.
//  Copyright © 2019 BTC. All rights reserved.
//

import XCTest

class StudyTest: XCTestCase {
    
    
    func testStudyList(){
        
        let response: [String: Any] = [
            "message": "SUCCESS",
            "studies": [
                [
                    "studyId": "PreganancyStudy",
                    "studyVersion": "1.5",
                    "title": "A Study for Women's Fitness.",
                    "category": "Drug Safety",
                    "sponsorName": " FDA",
                    "tagline": "Understanding factors that influence women's fitness",
                    "status": "Closed",
                    "logo": "http://172.246.126.44:8080/fdaResources/studylogo/STUDY_AP_09142018053627.jpeg?v=1550642300197",
                    "settings": [
                        "enrolling": true,
                        "platform": "ios",
                        "rejoin": true
                    ]
                ],
                [
                    "studyId": "Study001",
                    "studyVersion": "2.3",
                    "title": "A Study on the Human Eye",
                    "category": "Public Health",
                    "sponsorName": " FDA",
                    "tagline": "Gathering insights on eye-friendly lifestyles",
                    "status": "Active",
                    "logo": "http://172.246.126.44:8080/fdaResources/studylogo/STUDY_SS_05212018053722.jpg?v=1550642300203",
                    "settings": [
                        "enrolling": true,
                        "platform": "ios",
                        "rejoin": true
                    ]
                ],
                
            ]
        ]
        
        
        
    }
    
    
}
