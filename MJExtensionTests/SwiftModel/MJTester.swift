//
//  MJTester.swift
//  MJExtensionTests
//
//  Created by Frank on 2020/8/21.
//  Copyright © 2020 MJ Lee. All rights reserved.
//

import Foundation
import MJExtension

@objc(MJTester)
@objcMembers
class MJTester: NSObject {
    // make sure to use `dynamic` attribute for basic type & must use as Non-Optional & must set initial value
    dynamic var isSpecialAgent: Bool = false
    dynamic var age: Int = 0
    
    var name: String?
    var identifier: String?
}
