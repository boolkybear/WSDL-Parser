//
//  ViewController.swift
//  WSDLParser
//
//  Created by Boolky Bear on 13/2/15.
//  Copyright (c) 2015 ByBDesigns. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
	
	enum SegueIdentifier: String
	{
		case ServiceToPortsSegue = "PortsShowSegue"
	}

	@IBOutlet var urlField: NSTextField?
	@IBOutlet var tableView: NSTableView?
	
	var parser: WSDLParserDelegate? = nil
	
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
	}

	override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
		if let identifier = SegueIdentifier(rawValue: segue.identifier ?? "")
		{
			switch identifier
			{
			case .ServiceToPortsSegue:
				if let serviceIndex = sender as? NSNumber
				{
					if let service = self.parser?.definitions?.services[serviceIndex.integerValue]
					{
						let controller = segue.destinationController as PortsViewController
						controller.setDataOrigin(self.parser!, service: service)
					}
				}
			}
		}
	}
}

// Actions
extension ViewController
{
	@IBAction func parseButtonClicked(sender: AnyObject) {
		if let urlString = urlField?.stringValue
		{
			dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
				self.parser = self.wsdlParser(url: urlString)
				if let parser = self.parser
				{
					dispatch_async(dispatch_get_main_queue()) {
						self.tableView?.reloadData()
						
						return
					}
				}
			}
		}
	}
}

// NSTextField
extension ViewController: NSTextFieldDelegate
{
}

// NSTableView
extension ViewController: NSTableViewDataSource
{
	func numberOfRowsInTableView(aTableView: NSTableView) -> Int
	{
		return self.parser?.definitions?.services.count ?? 0
	}
	
	func tableView(aTableView: NSTableView,
		objectValueForTableColumn aTableColumn: NSTableColumn?,
		row rowIndex: Int) -> AnyObject?
	{
		let valueString = self.parser?.definitions?.services[rowIndex].name ?? ""
		
		return NSString(string: valueString)
	}
}

extension ViewController: NSTableViewDelegate
{
	func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
		let count = self.parser?.definitions?.services.count ?? 0
		
		if row < count
		{
			self.performSegueWithIdentifier("PortsShowSegue", sender: NSNumber(integer: row))
		}
		
		return row < count
	}
}

// Helpers
extension ViewController
{
	func wsdlParser(#url: String) -> WSDLParserDelegate?
	{
		if let url = NSURL(string: url)
		{
			if var parser = NSXMLParser(contentsOfURL: url)
			{
				var delegate = WSDLParserDelegate()
				parser.delegate = delegate
				parser.shouldReportNamespacePrefixes = true
				
				if parser.parse()
				{
					return delegate
				}
			}
		}
		
		return nil
	}
}