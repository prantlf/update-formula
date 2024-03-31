# update-formula

Updates version numbers and SHA-256 hashes in [Homebrew formula files] for GitHub releases. Helps updating a tap after publishing a new release on GitHub with new binary assets to install using Homebrew.

## Synopsis

An example of a formula:

```rb
class Yaml2json < Formula
  desc "Converts YAML input to JSON/JSON5 output."
  homepage "https://github.com/prantlf/v-yaml2json"
  version "0.2.0"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/prantlf/yaml2json/releases/download/v0.2.0/yaml2json-macos-x64.zip"
      sha256 "4bfd850ae85fdf539cfe2e30babbbe427896280ea7302191458d47489f646e3f"
    elsif Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/prantlf/yaml2json/releases/download/v0.2.0/yaml2json-macos-arm64.zip"
      sha256 "c124a4d8506c8a1cb79156f722bcb8ddbf62c9d53e89d0a15a0c7198d99f89e0"
    end
  end

 ...
```

Update version numbers and SHA-256 hashes to the latest available version:

    update-formula yaml2json.rb

## Usage

    update-formula [options] [<file> ...]

      <file>        formula file to update

    Options:
      -d|--dry-run  only print what would be done without doing it
      -V|--version  print the version of the executable and exit
      -h|--help     print the usage information and exit

## Contributing

In lieu of a formal styleguide, take care to maintain the existing coding style. Lint and test your code.

## License

Copyright (c) 2023-2024 Ferdinand Prantl

Licensed under the MIT license.

[Homebrew formula files]: https://docs.brew.sh/Formula-Cookbook
