//
//  WeatherTests.swift
//  WSDLParser
//
//  Created by Boolky Bear on 2/3/15.
//  Copyright (c) 2015 ByBDesigns. All rights reserved.
//

import Cocoa

class WeatherTests: XCTestCase {
	func testWork()
	{
		var isXMLDownloaded = false
		
		let expectation = expectationWithDescription("http://ws.cdyne.com/WeatherWS/GetWeatherInformation")
		Weather.GetWeatherInformationFunc(Weather.GetWeatherInformation()) {
			isXMLDownloaded = true
			
			expectation.fulfill()
		}
		
		waitForExpectationsWithTimeout(10) { (error) in
			XCTAssertNil(error, "\(error)")
		}

		XCTAssert(isXMLDownloaded, "XML has not been downloaded")
	}
}
