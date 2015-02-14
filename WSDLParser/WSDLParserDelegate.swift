//
//  WSDLParserDelegate.swift
//  WSDLParser
//
//  Created by Boolky Bear on 13/2/15.
//  Copyright (c) 2015 ByBDesigns. All rights reserved.
//

import Cocoa

enum WSDLTag: String {
	case Definitions = "wsdl:definitions"
	case Types = "wsdl:types"
	case Schema = "s:schema"
	case Import = "s:import"
	case Element = "s:element"
	case ComplexType = "s:complexType"
	case Sequence = "s:sequence"
}

typealias StringStack = Stack<String>

class WSDLParserDelegate: NSObject
{
	class Definitions {
		var targetNamespace: String? = nil
		var namespaces: [ String : String ] = [ String : String ]()
		
		var types: Types? = nil
	}
	
	class Types {
		var schemas: [ Schema ] = [Schema]()
		
		func appendSchema(schema: Schema)
		{
			self.schemas.append(schema)
		}
	}
	
	class Schema {
		var elementFormDefault: String? = nil
		var targetNamespace: String? = nil
		
		var importNamespaces: [ String ] = [String]()
		
		var elements: [ Element ] = [Element]()
		var complexTypes: [ ComplexType ] = [ComplexType]()
		
		func appendNamespace(namespace: String)
		{
			self.importNamespaces.append(namespace)
		}
		
		func appendElement(element: Element)
		{
			self.elements.append(element)
		}
		
		func appendComplexType(complexType: ComplexType)
		{
			self.complexTypes.append(complexType)
		}
	}
	
	class Element {
		var name: String? = nil
		
		// Schema Element
		var complexType: ComplexType? = nil
		
		// Sequence Element
		var minOccurs: Int = 0
		var maxOccurs: Int? = nil
		var type: String? = nil
		var isNillable: Bool = false
	}
	
	class ComplexType {
		// Schema Complex Type
		var name: String? = nil
		
		var sequence: Sequence? = nil
	}
	
	class Sequence {
		var elements: [ Element ] = [Element]()
		
		func appendElement(element: Element)
		{
			self.elements.append(element)
		}
	}

	private var stack: StringStack = StringStack()
	private var currentSchema: Schema? = nil
	private var currentElement: Element? = nil
	private var currentComplexType: ComplexType? = nil
	private var currentSequence: Sequence? = nil
	
	private(set) var definitions: Definitions? = nil
}

extension WSDLParserDelegate: NSXMLParserDelegate
{
	func parserDidStartDocument(parser: NSXMLParser)
	{
		self.stack = StringStack()
		
		self.definitions = nil
	}

	func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!)
	{
		let parentName = self.stack.top()
		
		self.stack.push(elementName)
		
		if let element = WSDLTag(rawValue: elementName)
		{
			switch element
			{
			case .Definitions:
				self.definitions = parseDefinitionsAttributes(attributeDict)
				
			case .Types:
				self.definitions?.types = Types()
				
			case .Schema:
				self.currentSchema = parseSchemaAttributes(attributeDict)
				if let currentSchema = self.currentSchema
				{
					self.definitions?.types?.appendSchema(currentSchema)
				}
				
			case .Import:
				parseImportAttributes(self.currentSchema, attributeDict: attributeDict)
				
			case .Element:
				if parentName == WSDLTag.Schema.rawValue
				{
					self.currentElement = parseSchemaElementAttributes(self.currentSchema, attributeDict: attributeDict)
				}
				else if parentName == WSDLTag.Sequence.rawValue
				{
					parseSequenceElementAttributes(self.currentSequence, attributeDict: attributeDict)
				}
				
			case .ComplexType:
				if parentName == WSDLTag.Schema.rawValue
				{
					self.currentComplexType = parseSchemaComplexTypeAttributes(self.currentSchema, attributeDict: attributeDict)
				}
				else if parentName == WSDLTag.Element.rawValue
				{
					self.currentComplexType = parseElementComplexTypeAttributes(self.currentElement, attributeDict: attributeDict)
				}
				
			case .Sequence:
				self.currentSequence = parseSequenceAttributes(self.currentComplexType, attributeDict: attributeDict)
			}
		}
	}
	
	func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!) {
		self.stack.pop()
		
		let parentName = self.stack.top()
		
		if let element = WSDLTag(rawValue: elementName)
		{
			switch element
			{
			case .Definitions: break
			case .Types: break
			
			case .Schema:
				self.currentSchema = nil
				
			case .Import: break
				
			case .Element:
				if parentName == WSDLTag.Schema.rawValue
				{
					self.currentElement = nil
				}
				
			case .ComplexType:
				self.currentComplexType = nil
				
			case .Sequence:
				self.currentSequence = nil
			}
		}
		
		
	}
}

// Helpers
extension WSDLParserDelegate
{
	func parseDefinitionsAttributes(attributeDict: [ NSObject : AnyObject ]) -> Definitions
	{
		let definitions = Definitions()
		
		definitions.targetNamespace = attributeDict["targetNamespace"] as? String
		
		attributeDict.filter { key, value in
			(key as? String)?.hasPrefix("xmlns:") ?? false
			}.each { key, value in
				definitions.namespaces[(key as? NSString)?.substringFromIndex(6) ?? NSString(string: "")] = (value as? String) ?? ""
		}
		
		return definitions
	}
	
	func parseSchemaAttributes(attributeDict: [ NSObject : AnyObject ]) -> Schema
	{
		let schema = Schema()
		
		schema.elementFormDefault = attributeDict["elementFormDefault"] as? String
		schema.targetNamespace = attributeDict["targetNamespace"] as? String
		
		return schema
	}
	
	func parseImportAttributes(schema: Schema?, attributeDict: [ NSObject : AnyObject ])
	{
		schema?.appendNamespace(attributeDict["namespace"] as? String ?? "")
	}
	
	func parseSchemaElementAttributes(schema: Schema?, attributeDict: [ NSObject : AnyObject ]) -> Element
	{
		let element = Element()
		
		element.name = attributeDict["name"] as? String
		
		schema?.appendElement(element)
		
		return element
	}
	
	func parseSequenceElementAttributes(sequence: Sequence?, attributeDict: [ NSObject : AnyObject ])
	{
		let element = Element()
		
		element.name = attributeDict["name"] as? String
		
		element.minOccurs = (attributeDict["minOccurs"] as? NSString)?.integerValue ?? 0
		if let maxOccurs = attributeDict["maxOccurs"] as? String
		{
			element.maxOccurs = maxOccurs == "unbounded" ? nil : maxOccurs.toInt()
		}
		else
		{
			element.maxOccurs = nil
		}
		
		element.isNillable = (attributeDict["nillable"] as? NSString)?.isEqualToString("true") ?? true
		element.type = attributeDict["type"] as? String
		
		sequence?.appendElement(element)
	}
	
	func parseSchemaComplexTypeAttributes(schema: Schema?, attributeDict: [ NSObject : AnyObject ]) -> ComplexType
	{
		let complexType = ComplexType()
		
		complexType.name = attributeDict["name"] as? String
		
		schema?.appendComplexType(complexType)
		
		return complexType
	}
	
	func parseElementComplexTypeAttributes(element: Element?, attributeDict: [ NSObject : AnyObject ]) -> ComplexType
	{
		let complexType = ComplexType()
		
		element?.complexType = complexType
		
		return complexType
	}
	
	func parseSequenceAttributes(complexType: ComplexType?, attributeDict: [ NSObject : AnyObject ]) -> Sequence
	{
		let sequence = Sequence()
		
		complexType?.sequence = sequence
		
		return sequence
	}
}