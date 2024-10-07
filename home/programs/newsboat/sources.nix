{ ... }:
let
  mkSource = tags: url: { inherit tags url; };
in {
  programs.newsboat.urls = [
    (mkSource [ "tech" "linux" ] "https://archlinux.org/feeds/news/")
    (mkSource [ "tech" "linux" "nixos" ] "https://nixos.org/blog/announcements-rss.xml")
    (mkSource [ "tech" "ntnu" ] "https://omegav.no/newsrss")
    (mkSource [ "ntnu" ] "https://varsel.it.ntnu.no/subscribe/rss/")
    (mkSource [ "tech" ] "https://blog.hackeriet.no/feed.xml")
    (mkSource [ "tech" ] "https://fribyte.no/rss.xml")
    (mkSource [ "tech" ] "https://existentialtype.wordpress.com/feed/")
    (mkSource [ "tech" "linux" "ntnu" ] "https://wiki.pvv.ntnu.no/w/api.php?hidebots=1&urlversion=1&days=90&limit=50&action=feedrecentchanges&format=xml")
    (mkSource [ "tech" "linux" "nixos" ] "https://dandellion.xyz/atom.xml")
    (mkSource [ "tech" "linux" ] "http://xahlee.info/comp/blog.xml")
    (mkSource [ "tech" ] "https://branchfree.org/feed/")
    (mkSource [ "tech" ] "https://search.marginalia.nu/news.xml")
    (mkSource [ "tech" "linux" ] "https://bartoszmilewski.com/feed/")
    (mkSource [ "tech" "linux" "nixos" ] "https://myme.no/atom-feed.xml")
    (mkSource [ "tech" "linux" "nixos" ] "https://blog.ysndr.de/atom.xml")
    (mkSource [ "tech" "linux" "nixos" ] "https://kaushikc.org/atom.xml")
    (mkSource [ "tech" "linux" "nixos" ] "https://ianthehenry.com/feed.xml")
    (mkSource [ "tech" "linux" "japanese" ] "https://www.ncaq.net/feed.atom")
    (mkSource [ "tech" "linux" "nixos" "emacs" "japanese" ] "https://apribase.net/program/feed")
    (mkSource [ "tech" "linux" "nixos" "functional-programming" ] "https://www.haskellforall.com/feeds/posts/default")
    (mkSource [ "tech" "linux" "nixos" ] "https://christine.website/blog.rss")
    (mkSource [ "tech" "functional-programming" "nixos" ] "https://markkarpov.com/feed.atom")
    (mkSource [ "tech" "functional-programming" ] "https://williamyaoh.com/feed.atom")
    (mkSource [ "tech" "functional-programming" ] "https://www.parsonsmatt.org/feed.xml")
    (mkSource [ "tech" "functional-programming" "python" ] "http://blog.ezyang.com/feed/")
    (mkSource [ "tech" "functional-programming" ] "https://lexi-lambda.github.io/feeds/all.rss.xml")
    (mkSource [ "tech" "functional-programming" ] "https://www.stephendiehl.com/feed.rss")
    (mkSource [ "tech" "functional-programming" "emacs" ] "https://chrisdone.com/rss.xml")
    (mkSource [ "tech" ] "https://go.dev/blog/feed.atom")
    (mkSource [ "tech" "linux" ] "https://jfx.ac/blog/index.xml")
    (mkSource [ "tech" "linux" ] "https://lukesmith.xyz/rss.xml")
    (mkSource [ "japanese" "language" ] "https://www.outlier-linguistics.com/blogs/japanese.atom")
    (mkSource [ "language" ] "https://feeds.feedburner.com/blogspot/Ckyi")
    (mkSource [ "japanese" "language" "old" ] "http://feeds.feedburner.com/LocalizingJapan")
    (mkSource [ "japanese" "language" ] "https://wesleycrobertson.wordpress.com/feed/")
    (mkSource [ "tech" "vim" "old" ] "https://castel.dev/rss.xml")
    (mkSource [ "tech" "functional-programming" "old" ] "https://skilpat.tumblr.com/rss")
    (mkSource [ "tech" ] "https://resocoder.com/feed/")

    # Broken?
    (mkSource [ "tech" "linux" "nixos" ] "https://flyx.org/feed.xml")
  ];
}
