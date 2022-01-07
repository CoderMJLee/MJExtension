//
//  MJCoreDataPerson+CoreDataProperties.swift
//  MJExtensionTests
//
//  Created by Frank on 2022/1/7.
//  Copyright © 2022 MJ Lee. All rights reserved.
//
//

import Foundation
import CoreData


extension MJCoreDataPerson {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MJCoreDataPerson> {
        return NSFetchRequest<MJCoreDataPerson>(entityName: "Person")
    }

    @NSManaged public var age: Int16
    @NSManaged public var name: String?
    @NSManaged public var tester: MJCoreDataTester?

}
