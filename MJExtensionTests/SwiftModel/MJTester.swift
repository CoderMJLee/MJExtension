//
//  MJTester.swift
//  MJExtensionTests
//
//  Created by Frank on 2020/8/21.
//  Copyright © 2020 MJ Lee. All rights reserved.
//

import Foundation
import MJExtension

@objc(MJSuperTester)
@objcMembers
class MJSuperTester: NSObject {
    // make sure to use `dynamic` attribute for basic type & must use as Non-Optional & must set initial value
    dynamic var isSpecialAgent: Bool = false
    dynamic var age: Int = 0
    
    var name: String?
    var identifier: String?
}

@objc(MJTester)
@objcMembers
class MJTester: MJSuperTester {
    var child: String?
}
