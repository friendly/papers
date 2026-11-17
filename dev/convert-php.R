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

page <- c(
  '<!DOCTYPE html>',
  '<html lang="en">',
  '<head>',
  '<meta charset="UTF-8">',
  '<meta name="viewport" content="width=device-width, initial-scale=1">',
  '<title>Michael Friendly: Papers and Presentations</title>',
  '<link rel="stylesheet" href="papers.css">',
  jquery_fancybox,
  '<script>$(function(){ $("a.lightbox").fancybox(); });</script>',
  '</head>',
  '<body>',
  '<header class="site">',
  '  <a href="https://friendly.github.io/">Michael Friendly</a>',
  '  <span class="crumbs">Publications: <a href="https://friendly.github.io/books.html">Books</a> | <b>Papers</b></span>',
  '  <span class="note">Papers formerly at <code>datavis.ca/papers/</code></span>',
  '</header>',
  '<main>',
  body,
  '</main>',
  '</body>',
  '</html>'
)
write(page, "index.html")

# ---- papers/ellipses/index.php ---------------------------------------------
ell <- read(file.path(src, "ellipses", "index.php"))
ell <- ell[-(1:grep("^\\?>", ell)[1])]                    # drop PHP preamble
ell <- ell[!grepl("head.js.tpl.php|fancybox-1.3.4.css", ell)]
ins <- grep('<script src="figlist.js">', ell, fixed = TRUE)
ell <- append(ell, jquery_fancybox, after = ins - 1)     # jQuery before figlist.js
ell <- gsub("http://www.datavis.ca/papers/ellipses",
            "https://friendly.github.io/papers/ellipses/", ell, fixed = TRUE)
stopifnot(!any(grepl("<?", ell, fixed = TRUE)))
write(abs_datavis(ell), file.path("ellipses", "index.html"))
