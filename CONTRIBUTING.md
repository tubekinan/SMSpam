# Contributing to SMSpam

Thank you for your interest in contributing to SMSpam! This document provides guidelines and instructions for contributing.

## Code of Conduct

By participating in this project, you are expected to uphold our code of conduct. Please read our [Code of Conduct](CODE_OF_CONDUCT.md) before contributing.

## How Can I Contribute?

### Reporting Bugs

Before submitting a bug report:
- Check the [existing issues](https://github.com/tubekinan/SMSpam/issues) to avoid duplicates
- Use the [bug report template](.github/ISSUE_TEMPLATE/bug_report.md) when creating an issue
- Include as much information as possible:
  - iOS version
  - Device model
  - Steps to reproduce
  - Expected vs actual behavior
  - Screenshots if applicable

### Suggesting Features

We welcome feature suggestions! Before submitting:
- Check [existing feature requests](https://github.com/tubekinan/SMSpam/issues?q=is%3Aissue+label%3Aenhancement)
- Use the [feature request template](.github/ISSUE_TEMPLATE/feature_request.md)
- Explain the use case and why it would benefit the project

### Pull Requests

1. **Fork the Repository**
   ```bash
   git clone https://github.com/tubekinan/SMSpam.git
   cd SMSpam
   ```

2. **Create a Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

3. **Make Your Changes**
   - Follow the existing code style and conventions
   - Write clean, well-documented code
   - Keep commits atomic and descriptive

4. **Test Your Changes**
   - Test on multiple iOS versions if possible
   - Ensure the app builds successfully
   - Test edge cases

5. **Commit Your Changes**
   ```bash
   git commit -m "Add: Brief description of your changes"
   ```

   Follow these commit message conventions:
   - `Add:` New feature
   - `Fix:` Bug fix
   - `Update:` Update existing feature
   - `Refactor:` Code refactoring
   - `Docs:` Documentation changes
   - `Style:` Formatting, no code change
   - `Test:` Adding tests
   - `Chore:` Maintenance tasks

6. **Push to Your Fork**
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Open a Pull Request**
   - Use a clear title and description
   - Reference any related issues
   - Ensure all checks pass

## Development Setup

### Requirements
- macOS (latest stable)
- Xcode 15.0+
- iOS 16.0+ simulator or device
- Swift 5.9+

### Building the Project
```bash
# Clone the repo
git clone https://github.com/tubekinan/SMSpam.git
cd SMSpam

# Open in Xcode
open SMSpam.xcodeproj

# Build and run (Cmd + R)
```

### Project Structure
```
SMSpam/
├── SMSpam/
│   ├── ContentView.swift      # Main UI
│   ├── LanguageManager.swift  # Localization
│   ├── SMSpamApp.swift        # App entry
│   └── Assets.xcassets/       # Assets
├── SpamFilterExtension/       # Message filter
└── SMSpam.xcodeproj/         # Project file
```

## Style Guidelines

### Swift Code
- Use Swift's modern syntax (Swift 5.9+)
- Follow [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/)
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused

### UI/UX
- Follow iOS Human Interface Guidelines
- Support both light and dark modes
- Use system colors when possible
- Maintain consistent spacing and alignment

### Localization
- All user-facing strings must use the `L()` function
- Support all 7 languages (TR, EN, DE, FR, ES, ZH-Hans, JA)
- Test in multiple languages

## Questions?

If you have any questions, feel free to:
- Open an issue for discussion
- Check our [discussions page](https://github.com/tubekinan/SMSpam/discussions)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
