//
//  PortsViewController.swift
//  WSDLParser
//
//  Created by Boolky Bear on 24/2/15.
//  Copyright (c) 2015 ByBDesigns. All rights reserved.
//

import Cocoa

class PortsViewController: NSViewController {
	
	var parser: WSDLParserDelegate?
	var service: WSDLParserDelegate.Service?

	@IBOutlet var tableView: NSTableView?
	
	enum Column: String
	{
		case Name = "nameColumn"
		case Binding = "bindingColumn"
		case Address = "addressColumn"
	}
	
	enum SegueIdentifier: String
	{
		case PortToBindingsShow = "BindingsShowSegue"
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
	
	func setDataOrigin(parser: WSDLParserDelegate, service: WSDLParserDelegate.Service)
	{
		self.parser = parser
		self.service = service
		
		let serviceName = service.name ?? "UNNAMED"
		self.title = "Ports of \(serviceName)"
		
		self.tableView?.reloadData()
	}
	
	override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
		if let identifier = SegueIdentifier(rawValue: segue.identifier ?? "")
		{
			switch identifier
			{
			case .PortToBindingsShow:
				if let portIndex = sender as? NSNumber
				{
					if let port = self.service?.ports[portIndex.integerValue]
					{
						if let binding = self.parser?.bindingNamed(port.binding ?? "")
						{
							let controller = segue.destinationController as OperationsViewController
							controller.setDataOrigin(self.parser!, binding: binding)
						}
					}
				}
			}
		}
	}
}

extension PortsViewController: NSTableViewDataSource
{
	func numberOfRowsInTableView(aTableView: NSTableView) -> Int
	{
		return service?.ports.count ?? 0
	}
	
	func tableView(aTableView: NSTableView,
		objectValueForTableColumn aTableColumn: NSTableColumn?,
		row rowIndex: Int) -> AnyObject?
	{
		let string: String? = {
			if let port = self.service?.ports[rowIndex]
			{
				if let column = Column(rawValue: aTableColumn?.identifier ?? "")
				{
					switch column
					{
					case .Name:
						return port.name
						
					case .Binding:
						return port.binding
						
					case .Address:
						return port.soapAddress?.location
					}
				}
			}
			
			return nil
		}()
		
		return NSString(string: string ?? "")
	}
}

extension PortsViewController: NSTableViewDelegate
{
	func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
		let count = self.service?.ports.count ?? 0
		
		if row < count
		{
			self.performSegueWithIdentifier(SegueIdentifier.PortToBindingsShow.rawValue, sender: NSNumber(integer: row))
		}
		
		return row < count
	}
}