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
	case Message = "wsdl:message"
	case Part = "wsdl:part"
	case PortType = "wsdl:portType"
	case Operation = "wsdl:operation"
	case Input = "wsdl:input"
	case Output = "wsdl:output"
	case Binding = "wsdl:binding"
	case SoapBinding = "soap:binding"
	case Soap12Binding = "soap12:binding"
	case SoapOperation = "soap:operation"
	case Soap12Operation = "soap12:operation"
	case SoapBody = "soap:body"
	case Soap12Body = "soap12:body"
	case Service = "wsdl:service"
	case Port = "wsdl:port"
	case SoapAddress = "soap:address"
	case Soap12Address = "soap12:address"
}

typealias StringStack = Stack<String>

class WSDLParserDelegate: NSObject
{
	class Definitions {
		var targetNamespace: String? = nil
		var namespaces: [ String : String ] = [ String : String ]()
		
		var types: Types? = nil
		var messages: [ Message ] = [Message]()
		var portTypes: [ PortType ] = [PortType]()
		var bindings: [ Binding ] = [Binding]()
		var services: [ Service ] = [Service]()
		
		func appendMessage(message: Message)
		{
			self.messages.append(message)
		}
		
		func appendPortType(portType: PortType)
		{
			self.portTypes.append(portType)
		}
		
		func appendBinding(binding: Binding)
		{
			self.bindings.append(binding)
		}
		
		func appendService(service: Service)
		{
			self.services.append(service)
		}
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
		
		func asOuterString() -> String
		{
			let complexString = self.complexType?.asString()
			let compoundString = self.type == nil ? "" : "Compound type \(self.type!) not yet supported\n"
			
			return "class \(self.name!) {\n" +
						(complexString ?? "") + "\n" +
						compoundString +
					"}"
		}
		
		func asInnerString() -> String
		{
			let varType: String = {
				switch (self.minOccurs, self.maxOccurs)
				{
				case (0, .Some):
					return "\(self.type!)?"
					
				case (1, .Some):
					return "\(self.type!)"
					
				case (_, nil):
					return "[\(self.type!)]"
					
				default:
					return "UNKNOWN"
				}
			}()
			
			return "var \(self.name!): \(varType)"
		}
	}
	
	class ComplexType {
		// Schema Complex Type
		var name: String? = nil
		
		var sequence: Sequence? = nil
		
		func asString() -> String
		{
			return self.sequence?.asString() ?? ""
		}
	}
	
	class Sequence {
		var elements: [ Element ] = [Element]()
		
		func appendElement(element: Element)
		{
			self.elements.append(element)
		}
		
		func asString() -> String
		{
			let elementStrings = self.elements.map { $0.asInnerString() }
			
			return join("\n", elementStrings)
		}
	}
	
	class Message {
		var name: String? = nil
		
		var parts: [ String : String ] = [String:String]()
	}
	
	class PortType {
		var name: String? = nil
		
		var operations: [ Operation ] = [Operation]()
		
		func appendOperation(operation: Operation)
		{
			self.operations.append(operation)
		}
		
		func operationNamed(name: String) -> Operation?
		{
			let cleanName = name.stringByRemovingTNSPrefix()
			
			let filteredOperations = self.operations.filter { $0.name == cleanName }
			if countElements(filteredOperations) == 1
			{
				return filteredOperations.first!
			}
			
			return nil
		}
	}
	
	class Operation {
		var name: String? = nil
		
		var input: InputOutput? = nil
		var output: InputOutput? = nil
		
		var soapOperation: SoapOperation? = nil
	}
	
	class InputOutput {
		var message: String? = nil
		
		var soapBody: SoapBody? = nil
	}
	
	class Binding {
		var name: String? = nil
		var type: String? = nil
		
		var soapBinding: SoapBinding? = nil
		var operations: [ Operation ] = [Operation]()
		
		func appendOperation(operation: Operation)
		{
			self.operations.append(operation)
		}
	}
	
	class SoapBinding {
		var transport: String? = nil
	}
	
	class SoapOperation {
		var soapAction: String? = nil
		var style: String? = nil
	}
	
	class SoapBody {
		var use: String? = nil
	}
	
	class Service {
		var name: String? = nil
		
		var ports: [ Port ] = [Port]()
		
		func appendPort(port: Port)
		{
			self.ports.append(port)
		}
	}
	
	class Port {
		var name: String? = nil
		var binding: String? = nil
		
		var soapAddress: SoapAddress? = nil
	}
	
	class SoapAddress {
		var location: String? = nil
	}

	private var stack: StringStack = StringStack()
	private var currentSchema: Schema? = nil
	private var currentElement: Element? = nil
	private var currentComplexType: ComplexType? = nil
	private var currentSequence: Sequence? = nil
	private var currentMessage: Message? = nil
	private var currentPortType: PortType? = nil
	private var currentOperation: Operation? = nil
	private var currentBinding: Binding? = nil
	private var currentInputOutput: InputOutput? = nil
	private var currentService: Service? = nil
	private var currentPort: Port? = nil
	
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
				
			case .Message:
				self.currentMessage = parseMessageAttributes(attributeDict)
				if let currentMessage = self.currentMessage
				{
					self.definitions?.appendMessage(currentMessage)
				}
				
			case .Part:
				parsePartAttributes(self.currentMessage, attributeDict: attributeDict)
				
			case .PortType:
				self.currentPortType = parsePortTypeAttributes(attributeDict)
				if let currentPortType = self.currentPortType
				{
					self.definitions?.appendPortType(currentPortType)
				}
				
			case .Operation:
				if parentName == WSDLTag.PortType.rawValue
				{
					self.currentOperation = parsePortTypeOperationAttributes(self.currentPortType, attributeDict: attributeDict)
				}
				else if parentName == WSDLTag.Binding.rawValue
				{
					self.currentOperation = parseBindingOperationAttributes(self.currentBinding, attributeDict: attributeDict)
				}
				
			case .Input:
				self.currentInputOutput = parseInputAttributes(self.currentOperation, attributeDict: attributeDict)
				
			case .Output:
				self.currentInputOutput = parseOutputAttributes(self.currentOperation, attributeDict: attributeDict)
				
			case .Binding:
				self.currentBinding = parseBindingAttributes(attributeDict)
				if let currentBinding = self.currentBinding
				{
					self.definitions?.appendBinding(currentBinding)
				}
				
			case .SoapBinding: fallthrough
			case .Soap12Binding:
				parseSoapBindingAttributes(self.currentBinding, attributeDict: attributeDict)
				
			case .SoapOperation: fallthrough
			case .Soap12Operation:
				parseSoapOperationAttributes(self.currentOperation, attributeDict: attributeDict)
				
			case .SoapBody: fallthrough
			case .Soap12Body:
				parseSoapBodyAttributes(self.currentInputOutput, attributeDict: attributeDict)
				
			case .Service:
				self.currentService = parseServiceAttributes(attributeDict)
				if let currentService = self.currentService
				{
					self.definitions?.appendService(currentService)
				}
				
			case .Port:
				self.currentPort = parsePortAttributes(self.currentService, attributeDict: attributeDict)
				
			case .SoapAddress: fallthrough
			case .Soap12Address:
				parseSoapAddressAttributes(self.currentPort, attributeDict: attributeDict)
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
				
			case .Message:
				self.currentMessage = nil
				
			case .Part: break
				
			case .PortType:
				self.currentPortType = nil
				
			case .Operation:
				self.currentOperation = nil
				
			case .Input: fallthrough
			case .Output:
				self.currentInputOutput = nil
				
			case .Binding:
				self.currentBinding = nil
				
			case .SoapBinding: fallthrough
			case .Soap12Binding: break
				
			case .SoapOperation: fallthrough
			case .Soap12Operation: break
				
			case .SoapBody: fallthrough
			case .Soap12Body: break
				
			case .Service:
				self.currentService = nil
				
			case .Port:
				self.currentPort = nil
				
			case .SoapAddress: fallthrough
			case .Soap12Address: break
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
	
	func parseMessageAttributes(attributeDict: [ NSObject : AnyObject ]) -> Message
	{
		let message = Message()
		
		message.name = attributeDict["name"] as? String
		
		return message
	}
	
	func parsePartAttributes(message: Message?, attributeDict: [ NSObject : AnyObject ])
	{
		message?.parts[(attributeDict["name"] as? String) ?? ""] = (attributeDict["element"] as? String) ?? ""
	}
	
	func parsePortTypeAttributes(attributeDict: [ NSObject : AnyObject ]) -> PortType
	{
		let portType = PortType()
		
		portType.name = attributeDict["name"] as? String
		
		return portType
	}
	
	func parsePortTypeOperationAttributes(portType: PortType?, attributeDict: [ NSObject : AnyObject ]) -> Operation
	{
		let operation = Operation()
		
		operation.name = attributeDict["name"] as? String
		
		portType?.appendOperation(operation)
		
		return operation
	}
	
	func parseInputAttributes(operation: Operation?, attributeDict: [ NSObject : AnyObject ]) -> InputOutput
	{
		let input = InputOutput()
		
		input.message = attributeDict["message"] as? String
		
		operation?.input = input
		
		return input
	}
	
	func parseOutputAttributes(operation: Operation?, attributeDict: [ NSObject : AnyObject ]) -> InputOutput
	{
		let output = InputOutput()
		
		output.message = attributeDict["message"] as? String
		
		operation?.output = output
		
		return output
	}
	
	func parseBindingAttributes(attributeDict: [ NSObject : AnyObject ]) -> Binding
	{
		let binding = Binding()
		
		binding.name = attributeDict["name"] as? String
		binding.type = attributeDict["type"] as? String
		
		return binding
	}
	
	func parseSoapBindingAttributes(binding: Binding?, attributeDict: [ NSObject : AnyObject ])
	{
		let soapBinding = SoapBinding()
		
		soapBinding.transport = attributeDict["transport"] as? String
		
		binding?.soapBinding = soapBinding
	}
	
	func parseBindingOperationAttributes(binding: Binding?, attributeDict: [ NSObject : AnyObject ]) -> Operation
	{
		let operation = Operation()
		
		operation.name = attributeDict["name"] as? String
		
		binding?.appendOperation(operation)
		
		return operation
	}
	
	func parseSoapOperationAttributes(operation: Operation?, attributeDict: [ NSObject : AnyObject ])
	{
		let soapOperation = SoapOperation()
		
		soapOperation.soapAction = attributeDict["soapAction"] as? String
		soapOperation.style = attributeDict["style"] as? String
		
		operation?.soapOperation = soapOperation
	}
	
	func parseSoapBodyAttributes(inputOutput: InputOutput?, attributeDict: [ NSObject : AnyObject ])
	{
		let soapBody = SoapBody()
		
		soapBody.use = attributeDict["use"] as? String
		
		inputOutput?.soapBody = soapBody
	}
	
	func parseServiceAttributes(attributeDict: [ NSObject : AnyObject ]) -> Service
	{
		let service = Service()
		
		service.name = attributeDict["name"] as? String
		
		return service
	}
	
	func parsePortAttributes(service: Service?, attributeDict: [ NSObject : AnyObject ]) -> Port
	{
		let port = Port()
		
		port.name = attributeDict["name"] as? String
		port.binding = attributeDict["binding"] as? String
		
		service?.appendPort(port)
		
		return port
	}
	
	func parseSoapAddressAttributes(port: Port?, attributeDict: [ NSObject : AnyObject ])
	{
		let soapAddress = SoapAddress()
		
		soapAddress.location = attributeDict["location"] as? String
		
		port?.soapAddress = soapAddress
	}
}

// Search
extension String
{
	func stringByRemovingTNSPrefix() -> String
	{
		if self.hasPrefix("tns:")
		{
			return self.substringFromIndex(advance(self.startIndex, 4))
		}
		
		return self
	}
}

extension WSDLParserDelegate
{
	func bindingNamed(name: String) -> Binding?
	{
		let cleanName = name.stringByRemovingTNSPrefix()
		
		if let bindings = self.definitions?.bindings.filter({ $0.name == cleanName })
		{
			if countElements(bindings) == 1
			{
				return bindings.first!
			}
		}
		
		return nil
	}
	
	func portTypeNamed(name: String) -> PortType?
	{
		let cleanName = name.stringByRemovingTNSPrefix()
		
		if let portTypes = self.definitions?.portTypes.filter({ $0.name == cleanName })
		{
			if countElements(portTypes) == 1
			{
				return portTypes.first!
			}
		}
		
		return nil
	}
	
	func messageNamed(name: String) -> Message?
	{
		let cleanName = name.stringByRemovingTNSPrefix()
		
		if let messages = self.definitions?.messages.filter({ $0.name == cleanName })
		{
			if countElements(messages) == 1
			{
				return messages.first!
			}
		}
		
		return nil
	}
	
	func elementNamed(name: String) -> Element?
	{
		let cleanName = name.stringByRemovingTNSPrefix()
		
		if let elements = self.definitions?.types?.schemas.first?.elements.filter({ $0.name == cleanName })
		{
			if countElements(elements) == 1
			{
				return elements.first!
			}
		}
		
		return nil
	}
}