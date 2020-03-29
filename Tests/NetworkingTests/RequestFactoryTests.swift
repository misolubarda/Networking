//
//  RequestFactoryTests.swift
//  
//
//  Created by Miso Lubarda on 24.03.20.
//

import XCTest
@testable import Networking

final class RequestFactoryTests: XCTestCase {
    private var endpointPath: String!
    private var baseURLPath: String!
    private var headerKey: HTTP.Header.Key!
    private var headerValue: HTTP.Header.Value!
    private var method: HTTP.Method!
    fileprivate var body: SomeBody!
    private var requestFactory: RequestFactory!

    override func setUp() {
        super.setUp()

        endpointPath = "endpointPath"
        baseURLPath = "http://google.com"
        headerKey = HTTP.Header.Key.contentType
        headerValue = HTTP.Header.Value.applicationJSON
        method = .get
        body = SomeBody(first: "first", second: "second")
        let baseURL = URL(string: baseURLPath)!
        requestFactory = RequestFactory(baseURL: baseURL, credentials: "")
    }

    override func tearDown() {
        super.tearDown()

        endpointPath = nil
        baseURLPath = nil
        headerKey = nil
        headerValue = nil
        method = nil
        body = nil
        requestFactory = nil
    }

    func test_urlRequest_whenAllDataProvided__noThrow() {
        XCTAssertNoThrow(try requestFactory.urlRequest(for: request))
    }

    func test_urlRequest_whenEndpointIsSet__urlConsistsOfBaseUrlAndEndpointPath() {
        let urlRequest = try! requestFactory.urlRequest(for: request)

        XCTAssertEqual(urlRequest.url?.absoluteString, baseURLPath + "/" + endpointPath)
    }

    func test_urlRequest_whenBodyIsProvided__bodyIsSet() {
        let urlRequest = try! requestFactory.urlRequest(for: requestWithBody)
        let bodyData = try! JSONEncoder().encode(body)

        XCTAssertEqual(urlRequest.httpBody, bodyData)
    }

    func test_urlRequest_whenHeaderFieldsProvided__headerFieldsAreSet() {
        let urlRequest = try! requestFactory.urlRequest(for: request)

        XCTAssertEqual(urlRequest.allHTTPHeaderFields?.count, 1)
        XCTAssertEqual(urlRequest.allHTTPHeaderFields?.first?.key, headerKey.rawValue)
        XCTAssertEqual(urlRequest.allHTTPHeaderFields?.first?.value, headerValue.rawValue)
    }

    fileprivate var request: Request {
        Request(endpointPath: endpointPath,
                headers: [headerKey : headerValue],
                method: method)
    }

    fileprivate var requestWithBody: RequestWithBody {
        RequestWithBody(endpointPath: endpointPath,
                        body: body,
                        headers: [headerKey : headerValue],
                        method: method)
    }
}

fileprivate struct SomeBody: Encodable {
    let first: String
    let second: String
}

fileprivate struct Request: RequestProtocol {
    let endpointPath: String
    var headers: [HTTP.Header.Key : HTTP.Header.Value]
    var method: HTTP.Method
}

fileprivate struct RequestWithBody: RequestProtocol, RequestBodyProtocol {
    let endpointPath: String
    var body: SomeBody?
    var headers: [HTTP.Header.Key : HTTP.Header.Value]
    var method: HTTP.Method
}
