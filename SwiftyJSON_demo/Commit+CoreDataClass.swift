//
//  Commit+CoreDataClass.swift
//  Project38
//
//  Created by Peter van den Hamer on 08/12/2023.
//
//

import Foundation
import CoreData

// https://www.hackingwithswift.com/read/38/4/creating-an-nsmanagedobject-subclass-with-xcode

@objc(Commit)
public class Commit: NSManagedObject {
    override public init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        print("Commit.Init() called!")
    }
}
