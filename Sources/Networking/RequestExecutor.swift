//
//  File.swift
//  
//
//  Created by Miso Lubarda on 24.03.20.
//

import Foundation

public protocol RequestExecutorProtocol {
    typealias DecodingTransform<T: Decodable> = (_ data: Data) throws -> T

    func execute<T: Decodable>(request: URLRequest, completion: @escaping (Result<T, Error>) -> Void)
    func execute<T: Decodable>(request: URLRequest, decoderTransformer: @escaping DecodingTransform<T>, completion: @escaping (Result<T, Error>) -> Void)
}

public class RequestExecutor {
    let session: URLSessionProtocol

    public init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
}

extension RequestExecutor: RequestExecutorProtocol {
    public func execute<T: Decodable>(request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
        execute(request: request, decoderTransformer: defaultDecoderTransformer(), completion: completion)
    }

    public func execute<T: Decodable>(request: URLRequest, decoderTransformer: @escaping DecodingTransform<T>, completion: @escaping (Result<T, Error>) -> Void) {
        let task = session.dataTask(with: request) { data, urlResponse, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data  {
                do {
                    let result = try decoderTransformer(data)
                    completion(.success(result))
                } catch let error {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(RequestExecutorError.ambigousResponse))
            }
        }
        task.resume()
    }

    private func defaultDecoderTransformer<T: Decodable>() -> DecodingTransform<T> {
        return { data in
            let decoder: JSONDecoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        }
    }
}

public enum RequestExecutorError: Error {
    case ambigousResponse
}
