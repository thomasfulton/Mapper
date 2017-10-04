# Mapper
Utility for easy deserialization of JSON in Swift. This is like a cross between SwiftyJSON and the `ImmutableMappable` in ObjectMapper. It allows you to easily extract types from JSON objects and arrays manually, but it fails with an `Error` instead of an optional.

## Example

```
let mapper = Mapper(json)

do {
    let name: String = try mapper.value("name")
} catch {}

let age: Int? = try? mapper.name("age")

do {
    let dateOfBirth: Date = try mapper.value("date_of_birth", using: DateFormatterTransform(dateFormatter: dateFormatter))
    let website: URL = try mapper.value("website", using: URLTransform())
    let gender: Gender = try mapper.value("gender", using: RawRepresentableTransform())
} catch {}
```

## TODOs
- `MappingError` needs to provide actual information on what went wrong, such as the key, type, and line number.
- The current handling of nested JSON can be a little clunky -- you have to instantiate a new `Mapper` for each nested JSON object or array. You should be able to provide a dot-separated key to extract nested types.
