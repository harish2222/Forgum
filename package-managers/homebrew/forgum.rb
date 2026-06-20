class Forgum < Formula
  desc "Cross-platform PowerShell module for cowsay, fortune, and lolcat"
  homepage "https://github.com/harish2222/Forgum"
  url "https://github.com/harish2222/Forgum/archive/refs/tags/v1.1.2.tar.gz"
  sha256 "C5489E4F9ED9182C64CFB7B8DC8B349F40438151CC33E2076978427D0C4E50E3"
  license "MIT"

  depends_on "powershell"

  def install
    prefix.install Dir["*"]
  end

  def caveats
    <<~EOS
      To use Forgum, add the following to your PowerShell profile:
        Import-Module #{prefix}/Forgum.psd1
    EOS
  end

  test do
    system "pwsh", "-Command", "Import-Module #{prefix}/Forgum.psd1; forgum cowsay 'Homebrew test'"
  end
end
