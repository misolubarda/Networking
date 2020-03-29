//
//  RequestExecutorTests.swift
//  
//
//  Created by Miso Lubarda on 26.03.20.
//

import XCTest
@testable import Networking

final class RequestExecutorTests: XCTestCase {
    fileprivate var fakeDecodable: FakeDecodable!
    fileprivate var fakeSession: FakeSession!
    private var requestExecutor: RequestExecutor!

    override func setUp() {
        super.setUp()

        fakeDecodable = FakeDecodable()
        let data = try? JSONEncoder().encode(fakeDecodable)
        fakeSession = FakeSession()
        fakeSession.data = data
        requestExecutor = RequestExecutor(session: fakeSession)
    }

    func test_execute_whenExecutingWithRequest__shouldStartSessionWithRequest() {
        let request = URLRequest(url: URL(string: "http://google.com")!)

        requestExecutor.execute(request: request) { (result: Result<FakeDecodable, Error>) in }

        XCTAssertEqual(fakeSession.dataTaskCallCount, 1)
        XCTAssertEqual(fakeSession.dataTaskWithRequest, request)
    }

    func test_execute_whenSessionReturnsData__shouldCompleteWithDto() {
        let request = URLRequest(url: URL(string: "http://google.com")!)
        let expectation = XCTestExpectation()
        var result: Result<FakeDecodable, Error>!

        requestExecutor.execute(request: request) { (res: Result<FakeDecodable, Error>) in
            result = res
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
        XCTAssertNoThrow(try result.get())
        XCTAssertEqual(try! result.get(), fakeDecodable)
    }

    func test_execute_whenSessionReturnsError__shouldCompleteWithError() {
        let request = URLRequest(url: URL(string: "http://google.com")!)
        fakeSession.error = FakeError()
        let expectation = XCTestExpectation()
        var result: Result<FakeDecodable, Error>!

        requestExecutor.execute(request: request) { (res: Result<FakeDecodable, Error>) in
            result = res
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
        XCTAssertThrowsError(try result.get()) { error in
            XCTAssertNotNil(error as? FakeError)
        }
    }

    func test_execute_whenCustomTransformProvided__shouldUseCustomTransformResult() {
        let request = URLRequest(url: URL(string: "http://google.com")!)
        let fakeTransform = FakeTransform()
        let expectedResult = FakeTransformDecodable()
        fakeTransform.customTransformReturn = expectedResult
        let expectation = XCTestExpectation()
        var result: Result<FakeTransformDecodable, Error>!

        requestExecutor.execute(request: request, decoderTransformer: fakeTransform.customTransform) { (res: Result<FakeTransformDecodable, Error>) in
            result = res
            expectation.fulfill()
        }

        XCTAssertEqual(fakeTransform.customTransformCalledCount, 1)
        wait(for: [expectation], timeout: 1)
        XCTAssertNoThrow(try result.get())
        XCTAssertEqual(try! result.get(), expectedResult)
    }

    func test_execute_whenCustomTransformFails__shouldCompleteWithError() {
        let request = URLRequest(url: URL(string: "http://google.com")!)
        let fakeTransform = FakeTransform()
        fakeTransform.customTransformError = FakeError()
        let expectation = XCTestExpectation()
        var result: Result<FakeTransformDecodable, Error>!

        requestExecutor.execute(request: request, decoderTransformer: fakeTransform.customTransform) { (res: Result<FakeTransformDecodable, Error>) in
            result = res
            expectation.fulfill()
        }

        XCTAssertEqual(fakeTransform.customTransformCalledCount, 1)
        wait(for: [expectation], timeout: 1)
        XCTAssertThrowsError(try result.get()) { error in
            XCTAssertNotNil(error as? FakeError)
        }
    }
}

fileprivate class FakeSession: URLSessionProtocol {
    var dataTaskCallCount = 0
    var dataTaskWithRequest: URLRequest?
    var data: Data?
    var urlResponse: URLResponse?
    var error: Error?

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        dataTaskCallCount += 1
        dataTaskWithRequest = request
        DispatchQueue.main.async {
            completionHandler(self.data, self.urlResponse, self.error)
        }

        return URLSessionDataTask()
    }
}

private struct FakeDecodable: Encodable, Decodable, Equatable {
    let id: String = "someId"
}

private struct FakeTransformDecodable: Decodable, Equatable {}

private struct FakeError: Error {}

private class FakeTransform {
    var customTransformCalledCount = 0
    var customTransformReturn: FakeTransformDecodable!
    var customTransformError: Error!

    var customTransform: RequestExecutor.DecodingTransform<FakeTransformDecodable> {
        customTransformCalledCount += 1
        return { data in
            if let error = self.customTransformError {
                throw error
            }
            return self.customTransformReturn
        }
    }
}
