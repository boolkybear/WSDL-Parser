//
//  Weather.swift
//  WSDLParser
//
//  Created by Boolky Bear on 2/3/15.
//  Copyright (c) 2015 ByBDesigns. All rights reserved.
//

import Foundation

import Alamofire

enum Result<T> {
	case Error(NSError)
	case Ok(Box<T>)
}

final public class Box<T> {
	public let unbox: T
	public init(_ value: T) { self.unbox = value }
}

struct Weather
{
	typealias GetWeatherInformationResponseHandler = (Result<GetWeatherInformationResponse>) -> Void
	
	struct GetWeatherInformation {
		
		func encode() -> String {
			return "<GetWeatherInformation />"
		}
	}
	
	struct GetWeatherInformationResponse {
		let GetWeatherInformationResult: ArrayOfWeatherDescription? = nil
	}
	
	struct WeatherDescriptionType {
		let WeatherID: Int16
		let Description: String?
		let PictureURL: String?
	}
	
	struct ArrayOfWeatherDescription {
		let WeatherDescription: [WeatherDescriptionType]
	}
	
	static func GetWeatherInformationFunc(input: GetWeatherInformation, handler: GetWeatherInformationResponseHandler)
	{
		if let url = NSURL(string: "http://wsf.cdyne.com/WeatherWS/Weather.asmx")
		{
			var request = NSMutableURLRequest(URL: url)
			request.HTTPMethod = "POST"
			request.addValue("http://ws.cdyne.com/WeatherWS/GetWeatherInformation", forHTTPHeaderField: "SOAPAction")
			request.addValue("text/xml;charset=UTF-8", forHTTPHeaderField: "Content-Type")
			
			let bodyString =	"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\">" +
									"<soapenv:Header />" +
									"<soapenv:Body>" +
										input.encode() +
									"</soapenv:Body>" +
								"</soapenv:Envelope>"
			
			request.HTTPBody = bodyString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
			
			let manager = Alamofire.Manager.sharedInstance
			let afrequest = manager.request(request)
			afrequest.responseString {
				(request, response, string, error) in
				
				if error != nil
				{
					handler(Result<GetWeatherInformationResponse>.Error(error!))
				}
				else
				{
					let box = Box<GetWeatherInformationResponse>(GetWeatherInformationResponse())
					handler(Result<GetWeatherInformationResponse>.Ok(box))
				}
			}
		}
	}
}
