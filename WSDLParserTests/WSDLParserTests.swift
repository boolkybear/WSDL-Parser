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
		
		self.parser = testWSDLParser("http://wsf.cdyne.com/WeatherWS/Weather.asmx?wsdl")
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
		let firstPortTypeOperation = firstPortType?.operations.first
		XCTAssertNotNil(firstPortTypeOperation, "First portType operation is nil")
		XCTAssertNotNil(firstPortTypeOperation?.input, "First portType operation input is nil")
		XCTAssertNotNil(firstPortTypeOperation?.output, "First portType operation output is nil")
	}
	
	func testBindings()
	{
		XCTAssert((self.parser?.definitions?.bindings.count ?? 0) > 0, "WSDL doesn't have any binding")
		
		let firstBinding = self.parser?.definitions?.bindings.first
		XCTAssertNotNil(firstBinding, "First binding is nil")
		XCTAssert((firstBinding?.operations.count ?? 0) > 0, "FirstBinding doesn't have any operations")
		XCTAssertNotNil(firstBinding?.name, "First binding name is nil")
		XCTAssertNotNil(firstBinding?.type, "First binding type is nil")
	}
	
	func testSoapBindings()
	{
		let firstBinding = self.parser?.definitions?.bindings.first
		XCTAssertNotNil(firstBinding, "First binding is nil")
		XCTAssertNotNil(firstBinding?.soapBinding, "First binding SOAP binding is nil")
		let firstOperation = firstBinding?.operations.first
		XCTAssertNotNil(firstOperation, "First operation of first binding is nil")
		XCTAssertNotNil(firstOperation?.soapOperation, "Soap operation of first operation is nil")
		XCTAssertNotNil(firstOperation?.input, "Input of first operation is nil")
		XCTAssertNotNil(firstOperation?.output, "Output of first operation is nil")
		XCTAssertNotNil(firstOperation?.input?.soapBody, "Soap body of first operation input is nil")
		XCTAssertNotNil(firstOperation?.output?.soapBody, "Soap body of first operation output is nil")
	}
	
	func testServices()
	{
		XCTAssert((self.parser?.definitions?.services.count ?? 0) > 0, "WSDL doesn't have any service")
		
		let firstService = self.parser?.definitions?.services.first
		XCTAssertNotNil(firstService, "First service is nil")
		XCTAssert((firstService?.ports.count ?? 0) > 0, "FirstService doesn't have any port")
		let firstPort = firstService?.ports.first
		XCTAssertNotNil(firstPort, "First port of first service is nil")
		XCTAssertNotNil(firstPort?.name, "First port name is nil")
		XCTAssertNotNil(firstPort?.binding, "First port binding is nil")
		XCTAssertNotNil(firstPort?.soapAddress, "First port soap address is nil")
		XCTAssertNotNil(firstPort?.soapAddress?.location, "First port soap address location is nil")
	}
}
