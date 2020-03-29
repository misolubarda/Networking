//
//  File.swift
//  
//
//  Created by Miso Lubarda on 24.03.20.
//

import Foundation

public protocol RequestFactoryProtocol {
    typealias EncodingTransform<T: Encodable> = (_ encodable: T) throws -> Data?

    func urlRequest<Request>(for request: Request) throws -> URLRequest where Request: RequestProtocol
    func urlRequest<Request>(for request: Request) throws -> URLRequest where Request: RequestProtocol & RequestBodyProtocol
    func urlRequest<Request>(for request: Request, transform: EncodingTransform<Request.Body>) throws -> URLRequest where Request: RequestProtocol & RequestBodyProtocol
}

// request with specified default transform
public class RequestFactory {
    let baseURL: URL
    let credentials: String

    public init(baseURL: URL, credentials: String) {
        self.baseURL = baseURL
        self.credentials = credentials
    }
}

extension RequestFactory: RequestFactoryProtocol {
    public func urlRequest<Request>(for request: Request) throws -> URLRequest where Request: RequestProtocol {
        return basicUrlRequest(for: request)
    }

    public func urlRequest<Request>(for request: Request) throws -> URLRequest where Request: RequestProtocol & RequestBodyProtocol {
        return try urlRequest(for: request, transform: defaultEncoderTransformer(Request.Body.self))
    }

    public func urlRequest<Request>(for request: Request, transform: (Request.Body) throws -> Data?) throws -> URLRequest where Request: RequestProtocol & RequestBodyProtocol {
        let urlRequest = basicUrlRequest(for: request)
        let urlRequestWithBody = try urlRequest.addBody(from: request, transform: transform)
        return urlRequestWithBody
    }

    private func basicUrlRequest(for request: RequestProtocol) -> URLRequest {
        // URL
        let url = baseURL.appendingPathComponent(request.endpointPath)
        var urlRequest = URLRequest(url: url)

        // Headers
        request.headers.forEach { urlRequest.addValue($0.value.rawValue, forHTTPHeaderField: $0.key.rawValue) }

        return urlRequest
    }

    private func defaultEncoderTransformer<T: Encodable>(_ input: T.Type) -> EncodingTransform<T> {
        return { encodable in
            let encoder: JSONEncoder = JSONEncoder()
            return try encoder.encode(encodable)
        }
    }
}

private extension URLRequest {
    func addBody<Request>(from request: Request, transform: (Request.Body) throws -> Data?) throws -> URLRequest where Request: RequestBodyProtocol {
        var urlRequest = self
        let body = request.body
        urlRequest.httpBody = try transform(body)
        return urlRequest
    }
}
