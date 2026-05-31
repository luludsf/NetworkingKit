# NetworkingKit

A lightweight networking layer for small Swift projects distributed with Swift Package Manager.

## Requirements

- iOS 15+
- macOS 12+

## Installation

### Xcode

1. Open `File > Add Package Dependencies...`
2. Enter your repository URL
3. Choose the desired version and add the package to your target

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/your-username/NetworkingKit.git", from: "1.0.0")
]
```

## Usage

```swift
import NetworkingKit

struct GamesRequest: Request {
    let host = "api.example.com"
    let scheme = "https"
    let version = "v1"
    let path = "/games"
    let method = HTTPMethod.get
}

let client = URLSessionClient()
let response: GamesResponse = try await client.perform(GamesRequest())
```

Optional request values such as `version`, `headers`, `body`, and `queryParams` can be omitted thanks to the protocol defaults.

## Testing
To run this project tests, run the command below in the root folder

```bash
swift test
```
