# RequestsCombine

Requests is a set of protocols and Combine publishers that makes integrating network requests easy. It uses a declarative style of defining a request, its result type, error type, as well as constructing the `URLRequest` and processing the data received, all in a single file. These requests can then be instantiated, configured, and will vend a publisher to execute the network request.

This enables testing the construction of a network request separately from how it is executed. The `URLRequest` construction, data processing, and error mapping can all be tested separately without a network connection or mocked `URLSession`.

---

## Installation

Install using the Swift Package Manager.

---

## Documentation

### Request

`Request` is the base protocol, which defines the `Success`/`Failure` types, a factory method to construct a `URLRequest`, and a function to map any upstream `Error`s to the `Request`'s `Failure` type.

`DataRequest` returns the raw data received by the network request. Implementors are free to do whatever they need to in order to transform the data to the desired `Success` type.

`DecodableRequest` allows for direct deserialization of `Decodable` objects, and also declares a `makeDecoder()` func to provide a custom `JSONDecoder`.

---

## Usage

* Create a request type that conforms to `DataRequest` or `DecodableRequest`
* Specify the `Success`/`Failure` typealiases
* Implement `makeURLRequest()`
* If you are implementing `DataRequest` directly, implement `processData()`, otherwise `DecodableRequest` provide a default implementation of this method

Example:

    struct Recipe: Decodable {
        let name: String
        let ingredients: [String]
        let steps: [String]
    }
    
    struct RecipeRequest: DecodableRequest {
        typealias Success = Recipe
        typealias Failure = Error

        let recipeId: String

        func makeURLRequest() -> Void {
            let url = URL(string: "https://recipes.com/fakeapi/recipe/\(recipeId)")!
            let urlRequest = URLRequest(url: url)
            return urlRequest
        }
    }

Now you have a `RecipeRequest` that returns a `Recipe` on success, execute it by creating a publisher and calling `sink()`:

    var cancellables: Set<AnyCancellable> = []
    
    let request = RecipeRequest(recipeId: "1")
    request.publisher().sink { result in
        if case let .failure(error) = result {
            print(error)
        }
    } receiveValue: { recipe in
        print("Recipe name: \(recipe.name)")
    }.store(in: &cancellables)
