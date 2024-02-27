//
//  WeatherAppTests.swift
//  WeatherAppTests
//
//  Created by 이다연 on 2023/01/19.
//

import XCTest
@testable import WeatherApp

final class WeatherAppTests: XCTestCase {
    
    var apiService = APIService.shared
    

    func testFetchData() {

        
        let expectation = self.expectation(description: "fetching data")

//        apiService.getHourlyWeather(city: "Seoul").subscribe(onNext: { data in
//            XCTAssertNotNil(data, "data should not be nil")
//            expectation.fulfill() // API 호출 성공
//        }, onError: { error in
//            XCTFail("error occured: \(error.localizedDescription)")
//            expectation.fulfill() // API 호출 실패
//        })

        // 비동기 테스트를 위한 타임아웃을 설정합니다.
        //waitForExpectations(timeout: 5.0, handler: nil)
        
        apiService.getDailyWeather(lat: 20, lon: 20).subscribe(onNext: { data in
            XCTAssertNotNil(data, "data should not be nil")
            expectation.fulfill() // API 호출 성공
        }, onError: { error in
            XCTFail("error occured: \(error.localizedDescription)")
            expectation.fulfill() // API 호출 실패
        })

    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
