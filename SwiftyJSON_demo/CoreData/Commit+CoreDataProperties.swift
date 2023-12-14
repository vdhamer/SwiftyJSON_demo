//
//  Commit+CoreDataProperties.swift
//  Project38
//
//  Created by Peter van den Hamer on 08/12/2023.
//
//

import Foundation
import CoreData

extension Commit {
    // https://www.hackingwithswift.com/read/38/4/creating-an-nsmanagedobject-subclass-with-xcode

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Commit> {
        return NSFetchRequest<Commit>(entityName: "Commit")
    }

    @NSManaged public var date: Date?
    @NSManaged public var message: String?
    @NSManaged public var sha: String?
    @NSManaged public var url: String?
    @NSManaged public var author: Author?

}

extension Commit: Identifiable {

}
