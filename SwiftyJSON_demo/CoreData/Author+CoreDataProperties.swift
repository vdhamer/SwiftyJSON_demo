//
//  Author+CoreDataProperties.swift
//  Project38
//
//  Created by Peter van den Hamer on 08/12/2023.
//
//

import Foundation
import CoreData

// https://www.hackingwithswift.com/read/38/8/adding-core-data-entity-relationships-lightweight-vs-heavyweight-migration

extension Author {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Author> {
        return NSFetchRequest<Author>(entityName: "Author")
    }

    @NSManaged public var name: String?
    @NSManaged public var email: String?
    @NSManaged public var commits: NSSet?

}

// MARK: Generated accessors for commits
extension Author {

    @objc(addCommitsObject:)
    @NSManaged public func addToCommits(_ value: Commit)

    @objc(removeCommitsObject:)
    @NSManaged public func removeFromCommits(_ value: Commit)

    @objc(addCommits:)
    @NSManaged public func addToCommits(_ values: NSSet)

    @objc(removeCommits:)
    @NSManaged public func removeFromCommits(_ values: NSSet)

}

extension Author: Identifiable {

}
