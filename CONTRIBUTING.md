# Contributing to Skills Bundle

First off, thanks for taking the time to contribute! 🎉

The following is a set of guidelines for contributing to `skills-bundle`. These are mostly guidelines, not rules. Use your best judgment, and feel free to propose changes to this document in a pull request.

## Code of Conduct

This project and everyone participating in it is governed by the [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

This section guides you through submitting a bug report. Following these guidelines helps maintainers and the community understand your report, reproduce the behavior, and find related reports.

- **Use the Bug Report template.** When identifying a bug, please use the provided template to ensure all necessary info is captured.
- **Describe the bug.** Explain the problem clearly.
- **Reproduce the bug.** Provide steps to reproduce the issue.

### Suggesting Enhancements

This section guides you through submitting an enhancement suggestion, including completely new features and minor improvements to existing functionality.

- **Use the Feature Request template.**
- **Describe the enhancement.** Explain what you want to achieve and why it would be useful.

### Pull Requests

- Fill in the required template
- Do not include issue numbers in the PR title
- Include screenshots and animated GIFs in your pull request whenever possible
- Follow the JavaScript styleguide
- End all files with a newline

## Styleguides

### Git Commit Messages

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters or less
- Reference issues and pull requests liberally after the first line

### Documentation

- Use [Markdown](https://daringfireball.net/projects/markdown/) for documentation.
- Keep the `README.md` and `SKILL.md` files up to date.

## Application Structure

- `bin/install.mjs`: The main installer script.
- `skills/`: Directory containing all skill definitions.
- `i18n/`: Translations.

## Setting Up Development Environment

1. Fork the repo and clone it.
2. Run `npm install` to install dependencies.
3. Use `npx .` to test the installer locally.

Thank you for contributing!
