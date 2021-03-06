class NanopbGenerator < Formula
  desc "C library for encoding and decoding Protocol Buffer messages"
  homepage "https://jpa.kapsi.fi/nanopb/docs/index.html"
  url "https://jpa.kapsi.fi/nanopb/download/nanopb-0.3.9.1.tar.gz"
  sha256 "e677290fdb419a3d437b824ef9eac02b8d1672fb30d60dd1f3113eae405b1f5b"

  bottle do
    cellar :any_skip_relocation
    sha256 "298fbe96efa71f53a4bfb7ae92d0e1cf31b8d9749611300ecc02dcefe20be9d8" => :high_sierra
    sha256 "298fbe96efa71f53a4bfb7ae92d0e1cf31b8d9749611300ecc02dcefe20be9d8" => :sierra
    sha256 "298fbe96efa71f53a4bfb7ae92d0e1cf31b8d9749611300ecc02dcefe20be9d8" => :el_capitan
    sha256 "a1d7a5a249a8b3736a109311b94dea672ec0696106a3d3aae9d7a4b13e8bea06" => :x86_64_linux
  end

  depends_on "python@2"
  depends_on "protobuf"

  conflicts_with "mesos",
    :because => "they depend on an incompatible version of protobuf"

  def install
    cd "generator" do
      system "make", "-C", "proto"
      inreplace "nanopb_generator.py", %r{^#!/usr/bin/env python$},
                                       "#!/usr/bin/python"
      libexec.install "nanopb_generator.py", "protoc-gen-nanopb", "proto"
      bin.install_symlink libexec/"protoc-gen-nanopb", libexec/"nanopb_generator.py"
    end
  end

  test do
    (testpath/"test.proto").write <<~EOS
      syntax = "proto2";

      message Test {
        required string test_field = 1;
      }
    EOS
    system Formula["protobuf"].bin/"protoc",
      "--proto_path=#{testpath}", "--plugin=#{bin}/protoc-gen-nanopb",
      "--nanopb_out=#{testpath}", testpath/"test.proto"
    system "grep", "test_field", testpath/"test.pb.c"
    system "grep", "test_field", testpath/"test.pb.h"
  end
end
