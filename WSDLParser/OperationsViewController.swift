//
//  OperationsViewController.swift
//  WSDLParser
//
//  Created by Boolky Bear on 24/2/15.
//  Copyright (c) 2015 ByBDesigns. All rights reserved.
//

import Cocoa

class OperationsViewController: NSViewController {

	var parser: WSDLParserDelegate?
	var binding: WSDLParserDelegate.Binding?
	var portType: WSDLParserDelegate.PortType?
	
	@IBOutlet var tableView: NSTableView?
	
	enum Column: String
	{
		case Operation = "operationColumn"
		case Action = "actionColumn"
//		case Input = "inputColumn"
//		case Output = "outputColumn"
	}
	
	enum SegueIdentifier: String
	{
		case OperationToMessagesShow = "MessagesShowSegue"
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.
	}
	
	func setDataOrigin(parser: WSDLParserDelegate, binding: WSDLParserDelegate.Binding)
	{
		self.parser = parser
		self.binding = binding
		
		if let type = binding.type
		{
			self.portType = parser.portTypeNamed(type)
		}
		
		let bindingName = binding.name ?? "UNNAMED"
		self.title = "Operations of \(bindingName)"
		
		self.tableView?.reloadData()
	}
	
	override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
		if let identifier = SegueIdentifier(rawValue: segue.identifier ?? "")
		{
			switch identifier
			{
			case .OperationToMessagesShow:
				if let operationIndex = sender as? NSNumber
				{
					if let operation = self.binding?.operations[operationIndex.integerValue]
					{
						// TODO: adjust show
//						if let bindingName = port.binding
//						{
//							let bindingIdentifier = bindingName.hasPrefix("tns:") ? bindingName.substringFromIndex(advance(bindingName.startIndex, 4)) : bindingName
//							let bindings = self.parser?.definitions?.bindings.filter { $0.name == bindingIdentifier }
//							if bindings?.count ?? 0 == 1
//							{
//								if let binding = bindings?.first
//								{
//									let controller = segue.destinationController as OperationsViewController
//									controller.setDataOrigin(self.parser!, service: service)
//								}
//							}
//						}
					}
				}
			}
		}
	}
}

extension OperationsViewController: NSTableViewDataSource
{
	func numberOfRowsInTableView(aTableView: NSTableView) -> Int
	{
		return binding?.operations.count ?? 0
	}
	
	func tableView(aTableView: NSTableView,
		objectValueForTableColumn aTableColumn: NSTableColumn?,
		row rowIndex: Int) -> AnyObject?
	{
		let string: String? = {
			if let operation = self.binding?.operations[rowIndex]
			{
				//let portTypeOperation = self.portType?.operationNamed(operation.name ?? "")
				
				if let column = Column(rawValue: aTableColumn?.identifier ?? "")
				{
					switch column
					{
					case .Operation:
						return operation.name
						
					case .Action:
						return operation.soapOperation?.soapAction
						
//					case .Input:
//						return portTypeOperation?.input?.message
//						
//					case .Output:
//						return portTypeOperation?.output?.message
					}
				}
			}
			
			return nil
			}()
		
		return NSString(string: string ?? "")
	}
}

extension OperationsViewController: NSTableViewDelegate
{
	func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
		let count = self.binding?.operations.count ?? 0
		
		if row < count
		{
			self.performSegueWithIdentifier(SegueIdentifier.OperationToMessagesShow.rawValue, sender: NSNumber(integer: row))
		}
		
		return row < count
	}
}
