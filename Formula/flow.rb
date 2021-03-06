class Flow < Formula
  desc "Static type checker for JavaScript"
  homepage "https://flowtype.org/"
  url "https://github.com/facebook/flow/archive/v0.70.0.tar.gz"
  sha256 "b3ed67553a45e57143a7c99e83bb9752ba670a081467140bc8bf92ca95887927"
  head "https://github.com/facebook/flow.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "97150237eb960009d34945e27228e6941cdf40504e004c78a3f92839a3b2232b" => :high_sierra
    sha256 "ee1b7585736f476e66ce890af944e0ab4df2cfd7c7de6e92021e0653a8a21280" => :sierra
    sha256 "466c180a63163f899222a200fdd2bb21a3a73c615cd2a413bea49369fc087908" => :el_capitan
    sha256 "80285ddbe7733c5e4d5ceb76209894fa80e85bb274be12de17ae2a24c41acf65" => :x86_64_linux
  end

  depends_on "ocaml" => :build
  depends_on "opam" => :build
  unless OS.mac?
    depends_on "m4" => :build
    depends_on "rsync" => :build
    depends_on "unzip" => :build
    depends_on "elfutils"
  end

  def install
    system "make", "all-homebrew"

    bin.install "bin/flow"

    bash_completion.install "resources/shell/bash-completion" => "flow-completion.bash"
    zsh_completion.install_symlink bash_completion/"flow-completion.bash" => "_flow"
  end

  test do
    system "#{bin}/flow", "init", testpath
    (testpath/"test.js").write <<~EOS
      /* @flow */
      var x: string = 123;
    EOS
    expected = /Found 1 error/
    assert_match expected, shell_output("#{bin}/flow check #{testpath}", 2)
  end
end
