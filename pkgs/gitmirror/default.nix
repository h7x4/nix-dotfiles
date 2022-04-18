{ buildGoModule, fetchFromGitHub }:
buildGoModule {
  pname = "gitmirror";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "dustin";
    repo = "gitmirror";
    rev = "9daaa97";
    sha256 = "2smiuFMrGEiKQapFJe7a1Fhs4mTPJ6jlQG6NHIqPZSM=";
  };

  vendorSha256 = "x9SK+CstG9pic9qkkdgrd+OvGax93X1N+oC/PKQ6Abs=";

  meta = {
    description = "A web server to receive webhooks and mirror git repos.";
    homepage = "https://github.com/dustin/gitmirror";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}

