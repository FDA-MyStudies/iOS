//
//  DBParticipantPropertyMetadata.swift
//  HPHC
//
//  Created by Tushar Katyal on 13/02/20.
//  Copyright © 2020 BTC. All rights reserved.
//

import RealmSwift

class DBParticipantPropertyMetadata: Object, Codable {
    
    // MARK: - Properties
    @objc dynamic var propertyType: String!
    @objc dynamic var propertyID: String!
    @objc dynamic var propertyDataFormat: String!
    @objc dynamic var shouldRefresh: Bool = false
    @objc dynamic var dataSource: String!
    @objc dynamic var status: String!
    @objc dynamic var externalPropertyID: String!
    @objc dynamic var dateOfEntryID: String!
    @objc dynamic var externalPropertyValue: String?
    @objc dynamic var dateOfEntryValue: String?
    @objc dynamic var propertyValue: String?
    
    required convenience init(ppMetaData: ParticipantPropertyMetadata) {
        self.init()
        self.propertyType = ppMetaData.propertyType
        self.propertyID = ppMetaData.propertyID
        self.propertyDataFormat = ppMetaData.propertyDataFormat
        self.shouldRefresh = ppMetaData.shouldRefresh
        self.dataSource = ppMetaData.dataSource
        self.status = ppMetaData.status
        self.externalPropertyID = ppMetaData.externalPropertyID
        self.dateOfEntryID = ppMetaData.dateOfEntryID
        self.externalPropertyValue = ppMetaData.externalPropertyValue
        self.dateOfEntryValue = ppMetaData.dateOfEntryValue
        self.propertyValue = ppMetaData.propertyValue
    }
}

extension DBParticipantPropertyMetadata {
    func wrap() -> JSONDictionary {
        return [:]
    }
}
