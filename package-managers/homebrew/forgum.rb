class Forgum < Formula
  desc "Cross-platform PowerShell module for cowsay, fortune, and lolcat"
  homepage "https://github.com/harish2222/Forgum"
  url "https://github.com/harish2222/Forgum/archive/refs/tags/v1.1.2.tar.gz"
  sha256 "REPLACE_ME"
  license "MIT"

  depends_on "powershell"

  def install
    prefix.install Dir["*"]
  end

  def caveats
    <<~EOS
      To use Forgum, add the following to your PowerShell profile:
        Import-Module #{prefix}/Forgum.psd1`n    EOS
  end

  test do
    system "pwsh", "-Command", "Import-Module #{prefix}/Forgum.psd1; Invoke-Cowsay -Text 'Homebrew test'"
  end
end
