import Foundation

final class Mapper {

    private let jsonObject: [String: Any]?
    private let jsonArray: [Any]?

    init(_ json: [String: Any]) {
        self.jsonObject = json
        self.jsonArray = nil
    }

    init(_ json: [Any]) {
        self.jsonObject = nil
        self.jsonArray = json
    }

    var count: Int {
        if let jsonObject = jsonObject {
            return jsonObject.count
        } else if let jsonArray = jsonArray {
            return jsonArray.count
        } else {
            return 0
        }
    }

    func value<T: Transform>(_ key: String, using transform: T) throws -> T.Object {
        if let object = jsonObject?[key], let t = transform.transform(input: object) {
            return t
        } else {
            throw MappingError()
        }
    }

    func value<T: Transform>(_ index: Int, using transform: T) throws -> T.Object {
        if index >= 0, index < jsonArray?.count ?? 0, let object = jsonArray?[index], let t = transform.transform(input: object) {
            return t
        } else {
            throw MappingError()
        }
    }

    func value<T>(_ key: String) throws -> T {
        if let t = jsonObject?[key] as? T {
            return t
        } else {
            throw MappingError()
        }
    }

    func value<T>(_ index: Int) throws -> T {
        if index >= 0, index < jsonArray?.count ?? 0, let t = jsonArray?[index] as? T {
            return t
        } else {
            throw MappingError()
        }
    }
}

protocol Transform {
    associatedtype Object
    func transform(input: Any) -> Object?
}

final class DateFormatterTransform: Transform {
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

final class URLTransform: Transform {
    typealias Object = URL

    func transform(input: Any) -> URL? {
        if let urlString = input as? String, let url = URL(string: urlString) {
            return url
        } else {
            return nil
        }
    }
}

final class RawRepresentableTransform<R: RawRepresentable>: Transform {
    typealias Object = R

    func transform(input: Any) -> R? {
        if let rawValue = input as? R.RawValue, let r = R(rawValue: rawValue) {
            return r
        } else {
            return nil
        }
    }
}

struct MappingError: Error {}
