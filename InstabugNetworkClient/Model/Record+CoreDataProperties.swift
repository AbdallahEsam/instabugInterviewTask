//
//  Record+CoreDataProperties.swift
//  InstabugInterview
//
//  Created by Abdallah Essam on 15/04/2022.
//
//

import Foundation
import CoreData


extension Record {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Record> {
        return NSFetchRequest<Record>(entityName: "Record")
    }

    @NSManaged public var url: String?
    @NSManaged public var statusCode: Int64
    @NSManaged public var responsePayload: String?
    @NSManaged public var requestPayload: String?
    @NSManaged public var method: String?
    @NSManaged public var errorDomain: String?
    @NSManaged public var createAt: Date?

}

extension Record : Identifiable {

}
