class Mypy < Formula
  desc "Experimental optional static type checker for Python"
  homepage "http://www.mypy-lang.org/"
  url "https://github.com/python/mypy.git",
      :tag => "v0.590",
      :revision => "7519e89ae8054ea3f22c4d13f16aaf9ae8f10f0a"
  head "https://github.com/python/mypy.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "d4929b99a6dcdb0383554a7714687da33b0876522f5d0f942ad11a8f5d15d874" => :high_sierra
    sha256 "26beb73bedfa44ab211b55ab02c4a97a04fd78f4b6b3bc6a6c60694103ebe470" => :sierra
    sha256 "a3b0e6bdc994be9692972ed91175cea4ff9e6bed04a828cc3179d7b0047b613d" => :el_capitan
    sha256 "5b75c7ebb8534c3ffab2b36ed41234809d37ad101aa9998c8f8bd06ce17843bb" => :x86_64_linux
  end

  option "without-sphinx-doc", "Don't build documentation"

  deprecated_option "without-docs" => "without-sphinx-doc"

  depends_on "python"
  depends_on "sphinx-doc" => [:build, :recommended]

  resource "psutil" do
    url "https://files.pythonhosted.org/packages/14/a2/8ac7dda36eac03950ec2668ab1b466314403031c83a95c5efc81d2acf163/psutil-5.4.5.tar.gz"
    sha256 "ebe293be36bb24b95cdefc5131635496e88b17fabbcf1e4bc9b5c01f5e489cfe"
  end

  resource "sphinx_rtd_theme" do
    url "https://files.pythonhosted.org/packages/36/02/f402fc35ab83ae757a70c43c6d078726e555064a2f461037582fac935649/sphinx_rtd_theme-0.3.0.tar.gz"
    sha256 "665135dfbdf8f1d218442458a18cf266444354b8c98eed93d1543f7e701cfdba"
  end

  resource "typed-ast" do
    url "https://files.pythonhosted.org/packages/52/cf/2ebc7d282f026e21eed4987e42e10964a077c13cfc168b42f3573a7f178c/typed-ast-1.1.0.tar.gz"
    sha256 "57fe287f0cdd9ceaf69e7b71a2e94a24b5d268b35df251a88fef5cc241bf73aa"
  end

  def install
    xy = Language::Python.major_minor_version "python3"

    if build.with? "sphinx-doc"
      # https://github.com/python/mypy/issues/2593
      version_static = buildpath/"mypy/version_static.py"
      version_static.write "__version__ = '#{version}'\n"
      inreplace "docs/source/conf.py", "mypy.version", "mypy.version_static"

      (buildpath/"docs/sphinx_rtd_theme").install resource("sphinx_rtd_theme")
      # Inject sphinx_rtd_theme's path into sys.path
      inreplace "docs/source/conf.py",
                "sys.path.insert(0, os.path.abspath('../..'))",
                "sys.path[:0] = [os.path.abspath('../..'), os.path.abspath('../sphinx_rtd_theme')]"
      system "make", "-C", "docs", "html"
      doc.install Dir["docs/build/html/*"]

      rm version_static
    end

    ENV.prepend_create_path "PYTHONPATH", libexec/"vendor/lib/python#{xy}/site-packages"
    resources.each do |r|
      r.stage do
        system "python3", *Language::Python.setup_install_args(libexec/"vendor")
      end
    end

    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python#{xy}/site-packages"
    system "python3", *Language::Python.setup_install_args(libexec)

    bin.install Dir[libexec/"bin/*"]
    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  test do
    (testpath/"broken.py").write <<~EOS
      def p() -> None:
        print('hello')
      a = p()
    EOS
    output = pipe_output("#{bin}/mypy broken.py 2>&1")
    assert_match '"p" does not return a value', output
  end
end
