import Foundation

public class Mapper {

    private let jsonObject: [String: Any]?
    private let jsonArray: [Any]?

    public init(_ json: [String: Any]) {
        self.jsonObject = json
        self.jsonArray = nil
    }

    public init(_ json: [Any]) {
        self.jsonObject = nil
        self.jsonArray = json
    }
    
    public func value<T: Transform>(_ key: String, using transform: T) throws -> T.Object {
        if let object = jsonObject?[key], let t = transform.transform(input: object) {
            return t
        } else {
            throw MappingError()
        }
    }

    public func value<T: Transform>(_ index: Int, using transform: T) throws -> T.Object {
        if index >= 0, index < jsonArray?.count ?? 0, let object = jsonArray?[index], let t = transform.transform(input: object) {
            return t
        } else {
            throw MappingError()
        }
    }

    public func value<T>(_ key: String) throws -> T {
        if let t = jsonObject?[key] as? T {
            return t
        } else {
            throw MappingError()
        }
    }

    public func value<T>(_ index: Int) throws -> T {
        if index >= 0, index < jsonArray?.count ?? 0, let t = jsonArray?[index] as? T {
            return t
        } else {
            throw MappingError()
        }
    }
}

public protocol Transform {
    associatedtype Object
    func transform(input: Any) -> Object?
}

public final class DateFormatterTransform: Transform {
    typealias Object = Date

    private let dateFormatter: DateFormatter

    init(dateFormatter: DateFormatter) {
        self.dateFormatter = dateFormatter
    }

    func transform(input: Any) -> Date? {
        if let dateString = input as? String, let date = dateFormatter.date(from: dateString) {
            return date
        } else {
            return nil
        }
    }
}

public class URLTransform: Transform {
    typealias Object = URL

    func transform(input: Any) -> URL? {
        if let urlString = input as? String, let url = URL(string: urlString) {
            return url
        } else {
            return nil
        }
    }
}

public class RawRepresentableTransform<R: RawRepresentable>: Transform {
    typealias Object = R

    func transform(input: Any) -> R? {
        if let rawValue = input as? R.RawValue, let r = R(rawValue: rawValue) {
            return r
        } else {
            return nil
        }
    }
}

public struct MappingError: Error {}
