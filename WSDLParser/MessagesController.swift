//
//  MessagesController.swift
//  WSDLParser
//
//  Created by Boolky Bear on 25/2/15.
//  Copyright (c) 2015 ByBDesigns. All rights reserved.
//

import Cocoa

class MessagesController: NSViewController {

	var parser: WSDLParserDelegate?
	var operation: WSDLParserDelegate.Operation?
	
	@IBOutlet var inputMessageLabel: NSTextFieldCell!
	@IBOutlet var outputMessageLabel: NSTextFieldCell!
	
	class MessageWrapper: NSObject {
		let message: WSDLParserDelegate.Message
		
		init(message: WSDLParserDelegate.Message)
		{
			self.message = message
			
			super.init()
		}
	}
	
	enum SegueIdentifier: String
	{
		case MessageToTypesShow = "TypesShowSegue"
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		self.inputMessageLabel?.stringValue = self.operation?.input?.message ?? ""
		self.outputMessageLabel?.stringValue = self.operation?.output?.message ?? ""
		
    }
 
	func setDataOrigin(parser: WSDLParserDelegate, operation: WSDLParserDelegate.Operation)
	{
		self.parser = parser
		self.operation = operation
		
		let operationName = operation.name ?? "UNNAMED"
		self.title = "Messages of \(operationName)"
		
		self.inputMessageLabel?.setValue(self.operation?.input?.message)
		self.outputMessageLabel?.setValue(self.operation?.output?.message)
	}
	
	override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
		if let identifier = SegueIdentifier(rawValue: segue.identifier ?? "")
		{
			switch identifier
			{
			case .MessageToTypesShow:
				if let messageWrapper = sender as? MessageWrapper
				{
					let controller = segue.destinationController as TypesViewController
					controller.setDataOrigin(self.parser!, message: messageWrapper.message)
				}
			}
		}
	}
}

// Actions
extension MessagesController
{
	func showMessageNamed(name: String?)
	{
		if let message = self.parser?.messageNamed(name ?? "")
		{
			self.performSegueWithIdentifier(SegueIdentifier.MessageToTypesShow.rawValue, sender: MessageWrapper(message: message))
		}
	}
	
	@IBAction func inputButtonClicked(sender: AnyObject) {
		self.showMessageNamed(self.operation?.input?.message)
	}
	
	@IBAction func outputButtonClicked(sender: AnyObject) {
		self.showMessageNamed(self.operation?.output?.message)
	}
}