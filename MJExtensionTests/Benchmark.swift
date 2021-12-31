//
//  Benchmark.swift
//  MJExtensionTests
//
//  Created by Frank on 2021/9/22.
//  Copyright © 2021 MJ Lee. All rights reserved.
//

import Foundation
import XCTest

class Benchmark: XCTestCase {
    var jsonObject = [[String: String]]()
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        for _ in 0...100000 {
            jsonObject.append(["jcol0":"test00","jcol1":"test01","jcol2":"test02","jcol3":"test03","jcol4":"test04","jcol5":"test05","jcol6":"test06","jcol7":"test07","jcol8":"test08","jcol9":"test09","jcol10":"test010","jcol11":"test011","jcol12":"test012","jcol13":"test013","jcol14":"test014","jcol15":"test015","jcol16":"test016","jcol17":"test017","jcol18":"test018","jcol19":"test019","jcol20":"test020","jcol21":"test021","jcol22":"test022","jcol23":"test023","jcol24":"test024","jcol25":"test025","jcol26":"test026","jcol27":"test027","jcol28":"test028","jcol29":"test029","jcol30":"test030"])
        }
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }
    
    func testPerformanceLargeFile() {
        // should about 4.x s in my mac (instead of 17s before refactorring)
        self.measure {
            let model = LargeModel.mj_objectArray(withKeyValuesArray: jsonObject)
            print("MJ")
        }
    }
}

@objc(LargeModel)
@objcMembers
class LargeModel: NSObject {
    var jcol0: String?
    var jcol1: String?
    var jcol2: String?
    var jcol3: String?
    var jcol4: String?
    var jcol5: String?
    var jcol6: String?
    var jcol7: String?
    var jcol8: String?
    var jcol9: String?
    var jcol10: String?
    var jcol11: String?
    var jcol12: String?
    var jcol13: String?
    var jcol14: String?
    var jcol15: String?
    var jcol16: String?
    var jcol17: String?
    var jcol18: String?
    var jcol19: String?
    var jcol20: String?
    var jcol21: String?
    var jcol22: String?
    var jcol23: String?
    var jcol24: String?
    var jcol25: String?
    var jcol26: String?
    var jcol27: String?
    var jcol28: String?
    var jcol29: String?
    var jcol30: String?
    var jcol31: String?
    var jcol32: String?
    var jcol33: String?
    var jcol34: String?
    var jcol35: String?
    var jcol36: String?
    var jcol37: String?
    var jcol38: String?
    var jcol39: String?
    var jcol40: String?
    var jcol41: String?
    var jcol42: String?
    var jcol43: String?
    var jcol44: String?
    var jcol45: String?
    var jcol46: String?
    var jcol47: String?
    var jcol48: String?
    var jcol49: String?
    var jcol50: String?
    var jcol51: String?
    var jcol52: String?
    var jcol53: String?
    var jcol54: String?
    var jcol55: String?
    var jcol56: String?
    var jcol57: String?
    var jcol58: String?
    var jcol59: String?
    var jcol60: String?
    var jcol61: String?
    var jcol62: String?
    var jcol63: String?
    var jcol64: String?
    var jcol65: String?
    var jcol66: String?
    var jcol67: String?
    var jcol68: String?
    var jcol69: String?
    var jcol70: String?
    var jcol71: String?
    var jcol72: String?
    var jcol73: String?
    var jcol74: String?
    var jcol75: String?
    var jcol76: String?
    var jcol77: String?
    var jcol78: String?
    var jcol79: String?
    var jcol80: String?
    var jcol81: String?
    var jcol82: String?
    var jcol83: String?
    var jcol84: String?
    var jcol85: String?
    var jcol86: String?
    var jcol87: String?
    var jcol88: String?
    var jcol89: String?
    var jcol90: String?
    var jcol91: String?
    var jcol92: String?
    var jcol93: String?
    var jcol94: String?
    var jcol95: String?
    var jcol96: String?
    var jcol97: String?
    var jcol98: String?
    var jcol99: String?
    var jcol100: String?
    var jcol101: String?
    
    var color: UIColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
    var color1: UIColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 1)
    var color2: UIColor = UIColor(patternImage: UIImage())
    var color3: UIColor = UIColor(hue: 1, saturation: 1, brightness: 1, alpha: 1)
    var color4: UIColor = UIColor(white: 1, alpha: 1)
}
