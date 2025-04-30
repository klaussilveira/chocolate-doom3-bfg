# Contributing to Chocolate DOOM3-BFG

Thank you for your interest in contributing to Chocolate DOOM3-BFG! This document provides guidelines and workflows to help you contribute effectively to our project.

## Project Philosophy

Before contributing, please understand that ChocolateDOOM3-BFG has a specific philosophy:

- Our goal is to accurately reproduce the experience of Vanilla Doom 3 on the modernized BFG engine
- We focus on fixing bugs, improving performance, and enhancing compatibility without altering the original gameplay experience or visual aesthetic
- We prioritize broad platform support and low system requirements

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** to your local machine
3. **Set up the development environment** (follow instructions in the README.md)
4. **Create a new branch** for your contribution:
   ```
   git checkout -b feature/your-feature-name
   ```

## What We Need

- Bug fixes for issues introduced in the BFG edition
- Performance optimizations that don't change gameplay or visuals
- Compatibility improvements for different platforms and hardware
- Documentation improvements
- Build system improvements

## Contribution Guidelines

### Code Style

- Follow the existing code style in the codebase
- Use meaningful variable and function names
- Comment your code where necessary to explain non-obvious behavior
- Keep functions small and focused on a single task when possible

### Commit Messages

- Use clear, descriptive commit messages
- Start with a brief summary (50 chars or less)
- Follow with a more detailed explanation if necessary
- Reference issue numbers when applicable

Example:
```
Fix broken collision detection on angled surfaces

This fixes a bug introduced in the BFG edition where players could clip
through certain angled surfaces, particularly in Hell levels.
Fixes issue #42.
```

### Pull Request Process

1. **Update your fork** with the latest changes from the main repository
2. **Test your changes** thoroughly before submitting
3. **Submit a pull request** with a clear description of:
   - What problem your PR solves
   - How your changes align with the project philosophy
   - Any testing you've performed
   - Screenshots/videos for visual changes (if applicable)
4. **Address review feedback** promptly if requested

## Feature Request Evaluation Criteria

Before implementing a new feature, consider whether it:

1. Maintains the authentic Doom 3 experience
2. Fixes a bug present in the BFG edition
3. Improves compatibility or performance without altering gameplay/visuals
4. Reduces system requirements or makes the game more accessible

If your feature idea doesn't meet these criteria, it may not be appropriate for Chocolate DOOM3-BFG. Consider if it might be better suited for a different Doom 3 source port like RBDOOM-3-BFG.

## Bug Reporting

If you find a bug but don't wish to fix it yourself, please report it by creating an issue with:

1. A clear, descriptive title
2. Detailed steps to reproduce the bug
3. Expected behavior vs. actual behavior
4. Your system specifications (OS, hardware, etc.)
5. Screenshots or videos if applicable

## License Considerations

By contributing to Chocolate DOOM3-BFG, you agree that your contributions will be licensed under the same license as the original project. Make sure any external code you incorporate is compatible with our license.

## Testing Guidelines

- Test your changes across multiple platforms if possible
- Pay particular attention to performance impact
- Verify that the original visual aesthetic and gameplay remain intact
- Check for regressions in previously working features

Thank you for helping make Chocolate DOOM3-BFG the most authentic Doom 3 experience possible while improving its technical foundation!