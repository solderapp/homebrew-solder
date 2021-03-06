require "formula"
require "language/go"
require "open-uri"

class KleisterCli < Formula
  desc "Manage mod packs for Minecraft - CLI"
  homepage "https://github.com/kleister/kleister-cli"

  head do
    url "https://github.com/kleister/kleister-cli.git", :branch => "master"
    depends_on "go" => :build
  end

  stable do
    url "https://dl.kleister.tech/cli/0.1.0/kleister-cli-0.1.0-darwin-amd64"
    sha256 begin
      open("https://dl.kleister.tech/cli/0.1.0/kleister-cli-0.1.0-darwin-amd64.sha256").read.split(" ").first
    rescue
      nil
    end
    version "0.1.0"
  end

  devel do
    url "https://dl.kleister.tech/cli/testing/kleister-cli-testing-darwin-amd64"
    sha256 begin
      open("https://dl.kleister.tech/cli/testing/kleister-cli-testing-darwin-amd64.sha256").read.split(" ").first
    rescue
      nil
    end
    version "master"
  end

  test do
    system "#{bin}/kleister-cli", "--version"
  end

  def install
    case
    when build.head?
      ENV["GOPATH"] = buildpath
      ENV["GOHOME"] = buildpath
      ENV["CGO_ENABLED"] = 0
      ENV["TAGS"] = ""

      ENV.prepend_create_path "PATH", buildpath / "bin"

      currentpath = buildpath / "kleister-cli"
      currentpath.install Dir["*"]
      Language::Go.stage_deps resources, buildpath / "src"

      cd currentpath do
        system "make", "test", "build"

        bin.install "bin/kleister-cli"
        # bash_completion.install "contrib/bash-completion/_kleister-cli"
        # zsh_completion.install "contrib/zsh-completion/_kleister-cli"
        prefix.install_metafiles
      end
    when build.devel?
      bin.install "#{buildpath}/kleister-cli-testing-darwin-amd64" => "kleister-cli"
    else
      bin.install "#{buildpath}/kleister-cli-0.1.0-darwin-amd64" => "kleister-cli"
    end
  end
end
