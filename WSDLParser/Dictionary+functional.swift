//
//  Dictionary+functional.swift
//  WSDLParser
//
//  Created by Boolky Bear on 13/2/15.
//  Copyright (c) 2015 ByBDesigns. All rights reserved.
//

import Foundation

extension Dictionary
{
	func filter(shouldContain: (Key,Value)->Bool) -> Dictionary<Key,Value>
	{
		var filteredDictionary = Dictionary<Key,Value>()
		
		for (key, value) in self
		{
			if shouldContain(key, value)
			{
				filteredDictionary[key] = value
			}
		}
		
		return filteredDictionary
	}
	
	func each(apply: (Key,Value)->Void)
	{
		for (key, value) in self
		{
			apply(key, value)
		}
	}
}