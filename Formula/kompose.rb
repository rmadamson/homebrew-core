class Kompose < Formula
  desc "Tool to move from `docker-compose` to Kubernetes"
  homepage "http://kompose.io"
  url "https://github.com/kubernetes/kompose/archive/v1.12.0.tar.gz"
  sha256 "fe3ddc38d71f0b406bccfbba026558479c4369b26a6e3887b32f14a9adebf3fa"

  bottle do
    cellar :any_skip_relocation
    sha256 "b6c2983763304c0b808aa1c84e71961d504bce84239f411ee8b6aa35ca1c07f2" => :high_sierra
    sha256 "17ac2b693de679ae5c9941ae8b6f7b4a0c0c3f3ff6071069a338bee009fbdc55" => :sierra
    sha256 "95fa1bbf6a2a06d9d532d47401fb129bbf73d8fd87b559b8a8843f2b7a07e6cc" => :el_capitan
    sha256 "64552d7efcd09be288593a253a1d2739a21abfe65990f6e6121923fad6aaf472" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    mkdir_p buildpath/"src/github.com/kubernetes"
    ln_s buildpath, buildpath/"src/github.com/kubernetes/kompose"
    system "make", "bin"
    bin.install "kompose"

    output = Utils.popen_read("#{bin}/kompose completion bash")
    (bash_completion/"kompose").write output

    output = Utils.popen_read("#{bin}/kompose completion zsh")
    (zsh_completion/"_kompose").write output
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/kompose version")
  end
end
