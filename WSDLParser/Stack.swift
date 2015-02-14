//
//  Stack.swift
//  CatViewer
//
//  Created by Boolky Bear on 6/2/15.
//  Copyright (c) 2015 ByBDesigns. All rights reserved.
//

import Foundation

// From Apple's swift book
struct Stack<T> {
	
	var items = [T]()
	
	mutating func push(item: T) {
		items.append(item)
	}
	
	mutating func pop() -> T {
		return items.removeLast()
	}
	
	func top() -> T?
	{
		return items.last
	}
}