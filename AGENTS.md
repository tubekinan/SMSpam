# Agents Configuration

This file contains instructions for automated agents (like OpenCode) working on this repository.

## General Guidelines

- Always respect the existing code style and conventions
- Make minimal, focused changes
- Ensure any new code is properly tested
- Update documentation when relevant
- Do not modify the TODO.md file except through the designated update process

## Task Types

When working on issues, please follow these patterns:

### Bug Fixes
1. Write a test that reproduces the issue
2. Fix the bug
3. Ensure all tests pass
4. Update any relevant documentation

### Feature Implementation
1. Check if design documents exist
2. Implement the feature following existing patterns
3. Add tests for new functionality
4. Update user documentation
5. Update API documentation if applicable

### Refactoring
1. Ensure existing tests pass before refactoring
2. Make small, incremental changes
3. Run tests frequently
4. Update documentation if interfaces change

## Commands

Commonly used commands:
- `swift test` - Run unit tests
- `swift lint` - Run SwiftLint (if configured)
- `xcodebuild test` - Run tests via xcodebuild

## Documentation

When updating documentation:
- Keep it concise and accurate
- Use the same tone as existing docs
- Update both in-code comments and external documentation
- Ensure screenshots are updated if UI changes

## Code Style

Follow the existing Swift style in the project:
- Use 4 spaces for indentation
- Prefer explicit types when they improve readability
- Use guard clauses for early exits
- Mark IBOutlets and IBActions appropriately
- Keep lines under 120 characters when possible

## Commit Messages

Write clear, descriptive commit messages:
- Start with a capital letter
- Use imperative mood ("Add feature" not "Added feature")
- Keep subject line under 72 characters
- Include a brief explanation in the body if needed
- Reference issue numbers when applicable: "Fixes #123"
