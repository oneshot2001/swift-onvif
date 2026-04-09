# Contributing to SwiftONVIF

Thanks for your interest in contributing! SwiftONVIF aims to be the definitive ONVIF library for the Swift ecosystem, and contributions are welcome.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/swift-onvif.git`
3. Create a branch: `git checkout -b feature/your-feature`
4. Make your changes
5. Run tests: `swift test`
6. Push and open a Pull Request

## Development Setup

SwiftONVIF is a standard Swift Package Manager project:

```bash
# Build
swift build

# Run tests
swift test

# Run the example CLI
swift run ONVIFExplorer
```

**Requirements:** Swift 5.9+, macOS 13+ (for development)

## Code Style

- Use Swift's standard naming conventions
- All public APIs need documentation comments
- New services and operations need corresponding test stubs
- Models should be `Sendable` and use value types where possible
- Async functions should use structured concurrency (no callbacks)

## Testing

- All ONVIF operations are tested against mock XML fixtures in `Tests/SwiftONVIFTests/Fixtures/`
- When adding a new operation, add a corresponding XML fixture file with a realistic response
- Test both success cases and SOAP fault handling
- If you have access to a physical ONVIF camera, real-device test results in your PR description are appreciated but not required

## Adding New ONVIF Operations

1. Add the method stub to the appropriate service in `Sources/SwiftONVIF/Services/`
2. Add any new models to `Sources/SwiftONVIF/Models/`
3. Add a mock XML response fixture to `Tests/SwiftONVIFTests/Fixtures/`
4. Add test cases
5. Update the "Supported ONVIF Operations" table in `README.md`

## Reporting Issues

- **Bugs:** Include the camera manufacturer/model, ONVIF version, and the SOAP response XML if possible
- **Feature requests:** Reference the ONVIF specification section if applicable
- **Security issues:** Email directly rather than opening a public issue

## Pull Request Guidelines

- Keep PRs focused on a single change
- Include tests for new functionality
- Update documentation if the public API changes
- Reference any related issues in the PR description

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
