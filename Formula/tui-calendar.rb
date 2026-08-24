class TuiCalendar < Formula
  desc "Keyboard-first Apple Calendar client for the terminal"
  homepage "https://github.com/dmshvedchenko/apple-tui-calendar"
  url "https://github.com/dmshvedchenko/apple-tui-calendar/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "4e9518ab4c103e0ca0b28224926382d8fa9ac48bdc4042673cead4b01b22e0ee"
  license "MIT"
  revision 1

  depends_on "rust" => :build
  depends_on :macos

  def install
    system "cargo", "install", *std_cargo_args
    cd "macos-calendar-service" do
      system "swift", "build", "-c", "release", "--disable-sandbox"
    end
    (libexec/"tui-calendar").install "macos-calendar-service/.build/release/tui-calendar-service"
  end

  def caveats
    <<~EOS
      On first launch, macOS asks for Calendar access. If access was denied,
      enable Terminal Calendar in System Settings > Privacy & Security > Calendars.
    EOS
  end

  test do
    assert_match(/^tui-calendar 1\.0\.0$/, shell_output("#{bin}/tui-calendar --version").strip)
    helper = libexec/"tui-calendar/tui-calendar-service"
    assert_predicate helper, :executable?
    input = %Q({"protocol":2,"id":1,"method":"authorizationStatus","params":{}}\n)
    assert_match(/"protocol":2,"id":1,/, pipe_output(helper, input))
  end
end
