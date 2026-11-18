# Convert the two templated PHP pages from the datavis.ca site into static HTML
# for the friendly/papers GitHub Pages site.
#
#   papers/index.php           -> index.html
#   papers/ellipses/index.php  -> ellipses/index.html
#
# Run from the repo root:  Rscript dev/convert-php.R [path/to/datavis/papers]

args <- commandArgs(trailingOnly = TRUE)
src  <- if (length(args)) args[1] else "C:/Dropbox/GitHub/datavis/papers"
stopifnot(dir.exists(src), file.exists("papers.Rproj"))

read  <- function(f) readLines(f, warn = FALSE, encoding = "UTF-8")
write <- function(x, f) { writeLines(x, f, useBytes = TRUE); message("wrote ", f) }

# links that leave papers/ (../gallery/, ../books/, ...) now point back to datavis.ca
abs_datavis <- function(x)
  gsub('(href|src)="\\.\\./', '\\1="https://www.datavis.ca/', x)

jquery_fancybox <- c(
  '<script src="https://code.jquery.com/jquery-3.3.1.min.js"></script>',
  '<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/fancybox/3.3.5/jquery.fancybox.min.css">',
  '<script src="https://cdnjs.cloudflare.com/ajax/libs/fancybox/3.3.5/jquery.fancybox.min.js"></script>'
)

# ---- papers/index.php -------------------------------------------------------
idx   <- read(file.path(src, "index.php"))
start <- grep("EDIT BELOW THIS LINE", idx) + 2
end   <- grep("EDIT ABOVE THIS LINE", idx) - 2
body  <- idx[start:end]

# inline the section navbar
nav_at <- grep("include 'navbar.php'", body, fixed = TRUE)
body   <- c(body[seq_len(nav_at - 1)], read(file.path(src, "navbar.php")),
            body[-seq_len(nav_at)])
stopifnot(!any(grepl("<?", body, fixed = TRUE)))
body <- abs_datavis(body)

# drop the commented-out menus and the stylesheets they used (Font Awesome, navbar.css)
body <- strsplit(gsub("(?s)<!--.*?-->", "", paste(body, collapse = "\n"), perl = TRUE), "\n")[[1]]
body <- body[!grepl("font-awesome|navbar[.]css", body)]
body <- body[!(grepl("^\\s*$", body) & c(FALSE, grepl("^\\s*$", head(body, -1))))]  # collapse blank runs

# drop a spam "translation" link (Guerry entry) hosted on a car-parts site
body <- sub('\\s*\\|\\|\\s*<a href="https://www.espertoautoricambi.it/[^"]*">[^<]*</a>', "", body)
stopifnot(!any(grepl("espertoautoricambi", body)))

# lightbox thumbnails whose full image is on datavis.ca/gallery (offline): show the local thumbnail
body <- gsub('<a class="lightbox" href="https://www.datavis.ca/gallery/[^"]*"><img src="([^"]+)"',
             '<a class="lightbox" href="\\1"><img src="\\1"', body)

# DDAR book: the friendly.github.io Books page has a section for it
body <- gsub('https://www.datavis.ca/books/#DDAR',
             'https://friendly.github.io/books.html#discrete-data-analysis-with-r', body, fixed = TRUE)
body <- gsub('https://www.datavis.ca/books/vcd/',
             'https://friendly.github.io/books.html#visualizing-categorical-data', body, fixed = TRUE)

# ---- site look: same Bootswatch themes, navbar and footer as friendly.github.io ----
# The Quarto site uses darkly (default) and cosmo (light), Bootstrap 5.3.1, with a toggle
# stored in localStorage "quarto-color-scheme" ("alternate" = dark, "default" = light).
# This page is on the same origin, so it reads and writes the same setting.
site <- "https://friendly.github.io/"
nav_item <- function(href, icon, text)
  sprintf('<li class="nav-item"><a class="nav-link" href="%s"><i class="bi bi-%s"></i> %s</a></li>',
          href, icon, text)

site_head <- function(css = "papers.css") c(
  '<link rel="icon" href="https://friendly.github.io/images/MF-face.png" type="image/png">',
  '<link id="theme-dark" rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootswatch@5.3.1/dist/darkly/bootstrap.min.css">',
  '<link id="theme-light" rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootswatch@5.3.1/dist/cosmo/bootstrap.min.css">',
  '<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">',
  '<script>',
  '  function setScheme(dark) {',
  '    document.getElementById("theme-dark").disabled = !dark;',
  '    document.getElementById("theme-light").disabled = dark;',
  '    document.documentElement.classList.toggle("dark", dark);',
  '  }',
  '  function schemeIsDark() {',
  '    try { return localStorage.getItem("quarto-color-scheme") !== "default"; } catch (e) { return true; }',
  '  }',
  '  function toggleScheme() {',
  '    var dark = !schemeIsDark();',
  '    try { localStorage.setItem("quarto-color-scheme", dark ? "alternate" : "default"); } catch (e) {}',
  '    setScheme(dark);',
  '  }',
  '  setScheme(schemeIsDark());',
  '</script>',
  sprintf('<link rel="stylesheet" href="%s">', css)
)

site_nav <- c(
  '<nav class="navbar navbar-expand-lg bg-primary sticky-top" data-bs-theme="dark">',
  '<div class="container-fluid">',
  sprintf('<a class="navbar-brand" href="%s">Michael Friendly</a>', site),
  '<button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarCollapse" aria-controls="navbarCollapse" aria-expanded="false" aria-label="Toggle navigation"><span class="navbar-toggler-icon"></span></button>',
  '<div class="collapse navbar-collapse" id="navbarCollapse">',
  '<ul class="navbar-nav me-auto">',
  nav_item(site, "house", "Home"),
  nav_item(paste0(site, "about.html"), "person", "About"),
  nav_item(paste0(site, "packages.html"), "box-seam", "R Packages"),
  '<li class="nav-item dropdown">',
  '<a class="nav-link dropdown-toggle active" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false"><i class="bi bi-book"></i> Publications</a>',
  '<ul class="dropdown-menu">',
  sprintf('<li><a class="dropdown-item" href="%sbooks.html">Books</a></li>', site),
  sprintf('<li><a class="dropdown-item active" aria-current="page" href="%spapers/">Papers</a></li>', site),
  '</ul>',
  '</li>',
  nav_item(paste0(site, "courses.html"), "mortarboard", "Courses"),
  nav_item(paste0(site, "software.html"), "code-slash", "Other Software"),
  nav_item(paste0(site, "blog/index.html"), "pencil", "Blog"),
  '</ul>',
  '<ul class="navbar-nav">',
  '<li class="nav-item"><a class="nav-link" href="https://github.com/friendly" aria-label="GitHub"><i class="bi bi-github"></i></a></li>',
  '<li class="nav-item"><a class="nav-link" href="https://bsky.app/profile/datavisfriendly.bsky.social" aria-label="BlueSky"><img src="https://friendly.github.io/images/bluesky-logo.png" alt="" style="height:1.2em; vertical-align:middle;"></a></li>',
  '<li class="nav-item"><a class="nav-link scheme-toggle" href="#" onclick="toggleScheme(); return false;" title="Toggle dark mode" aria-label="Toggle dark mode"><i class="bi bi-toggle-off"></i><i class="bi bi-toggle-on"></i></a></li>',
  '</ul>',
  '</div>',
  '</div>',
  '</nav>'
)

site_footer <- c(
  '<footer class="site-footer">',
  '  <span>Copyright 2025, Michael Friendly</span>',
  '  <span class="footer-note">Papers formerly at <code>datavis.ca/papers/</code></span>',
  sprintf('  <a href="%s">friendly.github.io/</a>', site),
  '</footer>',
  '<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/js/bootstrap.bundle.min.js"></script>'
)

page <- c(
  '<!DOCTYPE html>',
  '<html lang="en">',
  '<head>',
  '<meta charset="UTF-8">',
  '<meta name="viewport" content="width=device-width, initial-scale=1">',
  '<title>Michael Friendly: Papers and Presentations</title>',
  site_head(),
  jquery_fancybox,
  '<script>$(function(){ $("a.lightbox").fancybox(); });</script>',
  '</head>',
  '<body>',
  site_nav,
  '<main>',
  body,
  '</main>',
  site_footer,
  '</body>',
  '</html>'
)
write(page, "index.html")

# ---- papers/ellipses/index.php ---------------------------------------------
# Supplementary materials for the Elliptical Insights paper. Keep the original body
# (the figure gallery is built by figlist.js) inside the same site navbar, theme and footer.
ell <- read(file.path(src, "ellipses", "index.php"))
title    <- sub(".*<title>(.*)</title>.*", "\\1", grep("<title>", ell, value = TRUE)[1])
kw_start <- grep('<meta name="keywords"', ell, fixed = TRUE)
kw_end   <- kw_start + grep('">', ell[kw_start:length(ell)], fixed = TRUE)[1] - 1
keywords <- sub('value=', 'content=', ell[kw_start:kw_end], fixed = TRUE)
ell <- ell[(grep("<body>", ell, fixed = TRUE) + 1):(grep("</body>", ell, fixed = TRUE) - 1)]
# drop the "Updated <document.lastModified>" script: on GitHub Pages it is just the serve date
ell <- strsplit(gsub('(?s)\\s*<script language="JavaScript">.*?</script>', "",
                     paste(ell, collapse = "\n"), perl = TRUE), "\n")[[1]]
ell <- gsub("http://www.datavis.ca/papers/ellipses",
            "https://friendly.github.io/papers/ellipses/", ell, fixed = TRUE)
ell <- gsub("http://i.creativecommons.org/", "https://i.creativecommons.org/", ell, fixed = TRUE)
stopifnot(!any(grepl("<?", ell, fixed = TRUE)))

ell_page <- c(
  '<!DOCTYPE html>',
  '<html lang="en">',
  '<head>',
  '<meta charset="UTF-8">',
  '<meta name="viewport" content="width=device-width, initial-scale=1">',
  sprintf('<title>%s</title>', title),
  keywords,
  site_head("../papers.css"),
  jquery_fancybox,
  '<script src="figlist.js"></script>',
  '</head>',
  '<body>',
  site_nav,
  '<main class="ellipses">',
  abs_datavis(ell),
  '</main>',
  site_footer,
  '</body>',
  '</html>'
)
write(ell_page, file.path("ellipses", "index.html"))
