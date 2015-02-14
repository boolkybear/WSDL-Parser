//
//  WSDLParserTests.swift
//  WSDLParserTests
//
//  Created by Boolky Bear on 13/2/15.
//  Copyright (c) 2015 ByBDesigns. All rights reserved.
//

import Cocoa
import XCTest

func testWSDLParser(url: String) -> WSDLParserDelegate?
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

class WSDLParserTests: XCTestCase {
	
	var parser: WSDLParserDelegate? = nil
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
		
		self.parser = testWSDLParser("http://ws.cdyne.com/emailverify/Emailvernotestemail.asmx?wsdl")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
//    func testExample() {
//        // This is an example of a functional test case.
//        XCTAssert(true, "Pass")
//    }
//    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock() {
//            // Put the code you want to measure the time of here.
//        }
//    }
	
	func testParser()
	{
		XCTAssertNotNil(self.parser, "WSDL was not parsed")
	}
	
	func testDefinitions()
	{
		XCTAssertNotNil(self.parser?.definitions, "Definitions is nil")
		XCTAssertNotNil(self.parser?.definitions?.targetNamespace, "Target namespace is nil")
		XCTAssert((self.parser?.definitions?.namespaces.count ?? 0) > 0, "WSDL doesn't have any namespaces reference")
	}
	
	func testTypes()
	{
		XCTAssertNotNil(self.parser?.definitions?.types, "Types is nil")
	}
	
	func testSchemas()
	{
		XCTAssert((self.parser?.definitions?.types?.schemas.count ?? 0) > 0, "WSDL doesn't have any schemas")
		let firstSchema = self.parser?.definitions?.types?.schemas.first
		XCTAssertNotNil(firstSchema, "First schema is nil")
		XCTAssertNotNil(firstSchema?.targetNamespace, "Target namespace is nil")
		XCTAssertNotNil(firstSchema?.elementFormDefault, "Element form default is nil")
	}
	
//	func testSchemaImports()
//	{
//		let firstSchema = self.parser?.definitions?.types?.schemas.first
//		XCTAssertNotNil(firstSchema, "First schema is nil")
//		XCTAssert((firstSchema?.importNamespaces.count ?? 0) > 0, "Schema doesn't have any import")
//	}
	
	func testSchemaElements()
	{
		let firstSchema = self.parser?.definitions?.types?.schemas.first
		XCTAssertNotNil(firstSchema, "First schema is nil")
		XCTAssert((firstSchema?.elements.count ?? 0) > 0, "Schema doesn't have any element")
	}
	
	func testSchemaComplexTypes()
	{
		let firstSchema = self.parser?.definitions?.types?.schemas.first
		XCTAssertNotNil(firstSchema, "First schema is nil")
		XCTAssert((firstSchema?.complexTypes.count ?? 0) > 0, "Schema doesn't have any complex type")
	}
	
	func testMessages()
	{
		XCTAssert((self.parser?.definitions?.messages.count ?? 0) > 0, "WSDL doesn't have any message")
	}
	
	func testMessageParts()
	{
		let firstMessage = self.parser?.definitions?.messages.first
		XCTAssertNotNil(firstMessage, "First message is nil")
		XCTAssert((firstMessage?.parts.count ?? 0) > 0, "Message doesn't have any part")
	}
	
	func testPortTypes()
	{
		XCTAssert((self.parser?.definitions?.portTypes.count ?? 0) > 0, "WSDL doesn't have any portType")
	}
	
	func testPortTypeOperation()
	{
		let firstPortType = self.parser?.definitions?.portTypes.first
		XCTAssertNotNil(firstPortType, "First portType is nil")
		XCTAssertNotNil(firstPortType?.operation, "First portType operation is nil")
		XCTAssertNotNil(firstPortType?.operation?.input, "First portType operation input is nil")
		XCTAssertNotNil(firstPortType?.operation?.output, "First portType operation output is nil")
	}
	
	func testBindings()
	{
		XCTAssert((self.parser?.definitions?.bindings.count ?? 0) > 0, "WSDL doesn't have any binding")
		
		let firstBinding = self.parser?.definitions?.bindings.first
		XCTAssertNotNil(firstBinding, "First binding is nil")
		XCTAssertNotNil(firstBinding?.name, "First binding name is nil")
		XCTAssertNotNil(firstBinding?.type, "First binding type is nil")
	}
}
