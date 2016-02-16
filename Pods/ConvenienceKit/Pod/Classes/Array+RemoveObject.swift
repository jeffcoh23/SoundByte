//
//  Array+RemoveObject.swift
//  ConvenienceKit
//
//  Created by Benjamin Encz on 4/17/15.
//  Copyright (c) 2015 Benjamin Encz. All rights reserved.
//

import Foundation

// Thanks to Janos: http://stackoverflow.com/questions/24938948/array-extension-to-remove-object-by-value
public func removeObjectFromArray<T : Equatable>(object: T, inout array: [T])
{
  let index = array.indexOf(object)
  array.removeAtIndex(index!)
}