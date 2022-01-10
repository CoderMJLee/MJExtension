//
//  MJCDTesterInverseSelf+CoreDataProperties.swift
//  MJExtensionTests
//
//  Created by Frank on 2022/1/10.
//  Copyright © 2022 MJ Lee. All rights reserved.
//
//

import Foundation
import CoreData


extension MJCDTesterInverseSelf {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MJCDTesterInverseSelf> {
        return NSFetchRequest<MJCDTesterInverseSelf>(entityName: "MJCDTesterInverseSelf")
    }

    @NSManaged public var age: Int16
    @NSManaged public var identifier: String?
    @NSManaged public var isJuan: Bool
    @NSManaged public var name: String?
    @NSManaged public var relatives: Set<MJCDTesterInverseSelf>?

}

// MARK: Generated accessors for relatives
extension MJCDTesterInverseSelf {

    @objc(addRelativesObject:)
    @NSManaged public func addToRelatives(_ value: MJCDTesterInverseSelf)

    @objc(removeRelativesObject:)
    @NSManaged public func removeFromRelatives(_ value: MJCDTesterInverseSelf)

    @objc(addRelatives:)
    @NSManaged public func addToRelatives(_ values: NSSet)

    @objc(removeRelatives:)
    @NSManaged public func removeFromRelatives(_ values: NSSet)

}
