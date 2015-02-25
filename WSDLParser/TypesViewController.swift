//
//  TypesViewController.swift
//  WSDLParser
//
//  Created by Boolky Bear on 25/2/15.
//  Copyright (c) 2015 ByBDesigns. All rights reserved.
//

import Cocoa

class TypesViewController: NSViewController {

	var parser: WSDLParserDelegate?
	var message: WSDLParserDelegate.Message?
	
	@IBOutlet var typeTextView: NSTextView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		refreshText()
    }
	
	func setDataOrigin(parser: WSDLParserDelegate, message: WSDLParserDelegate.Message)
	{
		self.parser = parser
		self.message = message
		
		let messageName = message.name ?? "UNNAMED"
		self.title = "Types of \(messageName)"
	
		refreshText()
	}
}

extension TypesViewController
{
	func refreshText()
	{
		var elementNames = [String]()
		
		if let parts = self.message?.parts
		{
			for (key, value) in parts
			{
				elementNames.append(value)
			}
		}
		
		let elementStrings = elementNames.map {	self.parser?.elementNamed($0).map { $0.asOuterString() } ?? "" }
		
		self.typeTextView?.string = join("\n\n", elementStrings)
	}
}