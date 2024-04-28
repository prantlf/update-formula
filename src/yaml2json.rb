class Yaml2json < Formula
  desc "Converts YAML input to JSON/JSON5 output."
  homepage "https://github.com/prantlf/v-yaml2json"
  version "0.1.0"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/prantlf/yaml2json/releases/download/v0.2.0/yaml2json-macos-x64.zip"
      sha256 "4bfd850ae85fdf539cfe2e30babbbe427896280ea7302191458d47489f646e3f"
    elsif Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/prantlf/yaml2json/releases/download/v0.2.0/yaml2json-macos-arm64.zip"
      sha256 "c124a4d8506c8a1cb79156f722bcb8ddbf62c9d53e89d0a15a0c7198d99f89e0"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/prantlf/yaml2json/releases/download/v#{version}/yaml2json-linux-x64.zip"
      sha256 "7cce77866abdc8a91e6e8f76f768a97dc8b12b3b7c692c44eef351aa5f7b39a9"
    elsif Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/prantlf/yaml2json/releases/download/v#{version}/yaml2json-linux-arm64.zip"
      sha256 "487b517076b3e4ed8bca260093c190f870b3defd0c0dffa85718b4f10bbdfc71"
    end
  end

  def install
    bin.install "bin/yaml2json"
    man1.install "man/yaml2json.1"
  end

  test do
    system "#{bin}/yaml2json", "-V"
  end
end
