//
//  ifNotNil.swift
//  CatViewer
//
//  Created by Boolky Bear on 6/2/15.
//  Copyright (c) 2015 ByBDesigns. All rights reserved.
//

import Foundation

func ifNotNil<T>(params: [T?], process: ([T])->Void)
{
	let nilParams = params.filter { $0 == nil }
	if countElements(nilParams) == 0
	{
		process(params.map { $0! })
	}
}

func ifNotNil<T>(process: ([T])->Void, params:T?...)
{
	ifNotNil(params.map { $0 }, process)
}

func ifNotNil<T, U>(a: T?, b: U?, process: (T, U)->Void)
{
	switch (a, b)
	{
	case (.Some(let a), .Some(let b)):
		process(a, b)
	default:
		break
	}
}

func ifNotNil<T, U, V>(a: T?, b: U?, c: V?, process: (T, U, V)->Void)
{
	ifNotNil(a, b) {
		a, b in
		if let c = c
		{
			process(a, b, c)
		}
	}
}

func ifNotNil<T, U, V, W>(a: T?, b: U?, c: V?, d: W?, process: (T, U, V, W)->Void)
{
	ifNotNil(a, b, c) {
		a, b, c in
		if let d = d
		{
			process(a, b, c, d)
		}
	}
}
