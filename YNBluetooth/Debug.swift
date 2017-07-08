//
//  Debug.swift
//  YNBluetooth
//
//  Created by yuyan7 on 2017/07/08.
//  Copyright © 2017年 yuyan7. All rights reserved.
//

#if DEBUG
let interval = TimeInterval(TimeZone.current.secondsFromGMT())
#endif

func debugLog(_ obj: Any?, function: String = #function, line: Int = #line) {
    #if DEBUG
        if let obj = obj {
            print("\(Date(timeIntervalSinceNow: interval)) [Function:\(function) Line:\(line)] : \(obj)")
        } else {
            print("\(Date(timeIntervalSinceNow: interval))1 [Function:\(function) Line:\(line)]")
        }
    #endif
}
