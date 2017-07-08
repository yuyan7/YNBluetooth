//
//  WeakRef.swift
//  YNBluetooth
//
//  Created by yuyan7 on 2017/07/08.
//  Copyright © 2017年 yuyan7. All rights reserved.
//
import Foundation

/// WeakRef
public class WeakRef<T> where T: AnyObject {

    /// weak value
    private(set) weak var value: T?

    /// Initializer
    ///
    /// - Parameter value: Value
    init(value: T?) {
        self.value = value
    }
}
