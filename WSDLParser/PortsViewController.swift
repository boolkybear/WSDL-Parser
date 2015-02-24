//
//  PortsViewController.swift
//  WSDLParser
//
//  Created by Dylvian on 24/2/15.
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
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
	
	func setDataOrigin(parser: WSDLParserDelegate, service: WSDLParserDelegate.Service)
	{
		self.parser = parser
		self.service = service
		
		self.tableView?.reloadData()
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