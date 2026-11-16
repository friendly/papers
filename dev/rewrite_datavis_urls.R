# Rewrite links to the (offline) datavis.ca site in an R package or other project.
#
#   source("C:/R/Projects/papers/dev/rewrite_datavis_urls.R")
#   res <- rewrite_datavis_urls("C:/R/Projects/vcdExtra")                 # dry run: report only
#   res <- rewrite_datavis_urls("C:/R/Projects/vcdExtra", dry_run = FALSE) # edit files
#
# Each datavis.ca URL is mapped as follows:
#   1. known broken paths are fixed (effect.pdf, mosahist.pdf, Corrgrams.pdf, palers/)
#   2. papers with a published version -> https://doi.org/...   (DOIs from vita.bib)
#   3. other papers/... and mosaics/... -> https://friendly.github.io/papers/...
#   4. the bare site root                -> https://friendly.github.io/
#   5. anything else (gallery/, milestones/, books/, online/, sasmac/, ddar.datavis.ca)
#      is left alone and reported as "unmapped", for a decision by hand.
#
# Only source files are edited; man/*.Rd must then be regenerated with devtools::document().

papers_repo <- "C:/R/Projects/papers"   # local clone of friendly/papers, to check targets exist
new_base    <- "https://friendly.github.io/papers/"

# Path fixes: old path -> correct path (relative to datavis.ca/)
path_fixes <- c(
  "papers/effect.pdf"    = "papers/effect/effect.pdf",
  "papers/mosahist.pdf"  = "papers/moshist.pdf",
  "papers/Corrgrams.pdf" = "papers/corrgram.pdf",
  "mosaics/mosaics.pdf"  = "papers/mosaics/mosaics.pdf"
)

# Published versions, keyed by (fixed) path. DOIs verified against vita.bib, 2026-11-16.
doi_map <- c(
  "papers/jcgs-heplots.pdf"                       = "10.1198/106186007X208407",
  "papers/ellipses.pdf"                           = "10.1214/12-STS402",
  "papers/ellipses-STS402.pdf"                    = "10.1214/12-STS402",
  "papers/genridge.pdf"                           = "10.1080/10618600.2012.681237",
  "papers/genridge-jcgs.pdf"                      = "10.1080/10618600.2012.681237",
  "papers/viscollin-tast.pdf"                     = "10.1198/tast.2009.0012",
  "papers/effect/effect.pdf"                      = "10.1016/S0167-9473(02)00290-6",
  "papers/golden-STS268.pdf"                      = "10.1214/08-STS268",
  "papers/guerryvie/GuerryLife2-SocSpectrum.pdf"  = "10.1080/02732173.2022.2078450"
)

default_globs <- c("DESCRIPTION", "README.Rmd", "README.md", "NEWS.md", "_pkgdown.yml",
                   "R/*.R", "vignettes/*.Rmd", "vignettes/*.qmd", "vignettes/*.bib",
                   "inst/CITATION", "*.qmd", "*.bib")

# A datavis.ca URL, any host variant (www., ddar., none), up to a delimiter.
url_regex <- "https?://([a-z]+\\.)?datavis\\.ca[^][[:space:]<>(){}\"'`|,;]*"

map_datavis_url <- function(url) {
  u <- sub("[.]+$", "", url)                       # trailing sentence period
  host <- sub("^https?://([^/]+).*$", "\\1", u)
  if (!host %in% c("datavis.ca", "www.datavis.ca")) return(NA_character_)
  path <- sub("^https?://[^/]+/?", "", u)
  path <- sub("^palers/", "papers/", path)
  if (path %in% names(path_fixes)) path <- path_fixes[[path]]
  if (path %in% names(doi_map)) {
    # encode ( ) so the URL is safe inside markdown links: [text](url)
    doi <- gsub(")", "%29", gsub("(", "%28", doi_map[[path]], fixed = TRUE), fixed = TRUE)
    return(paste0("https://doi.org/", doi))
  }
  if (path == "")                return("https://friendly.github.io/")
  if (startsWith(path, "papers"))
    return(paste0(new_base, sub("^papers/?", "", path)))
  NA_character_
}

target_exists <- function(new) {
  if (!startsWith(new, new_base)) return(NA)
  rel <- utils::URLdecode(sub(new_base, "", new, fixed = TRUE))
  rel <- sub("#.*$", "", rel)
  p   <- file.path(papers_repo, rel)
  file.exists(p) || file.exists(file.path(p, "index.html"))
}

rewrite_datavis_urls <- function(dir, dry_run = TRUE, globs = default_globs) {
  files <- unique(unlist(lapply(file.path(dir, globs), Sys.glob)))
  files <- files[file.exists(files) & !dir.exists(files)]
  out <- list()
  for (f in files) {
    lines <- readLines(f, warn = FALSE, encoding = "UTF-8")
    changed <- FALSE
    for (i in grep("datavis\\.ca", lines)) {
      urls <- unique(regmatches(lines[i], gregexpr(url_regex, lines[i], perl = TRUE))[[1]])
      for (u in urls) {
        old <- sub("[.]+$", "", u)
        new <- map_datavis_url(old)
        # in .bib files % starts a LaTeX comment; raw ( ) are fine inside braces
        if (!is.na(new) && grepl("\\.bib$", f, ignore.case = TRUE))
          new <- gsub("%29", ")", gsub("%28", "(", new, fixed = TRUE), fixed = TRUE)
        out[[length(out) + 1]] <- data.frame(
          file = sub(paste0(normalizePath(dir, "/"), "/"), "", normalizePath(f, "/"), fixed = TRUE),
          line = i, old = old, new = new,
          exists = if (is.na(new)) NA else target_exists(new))
        if (!is.na(new)) {
          # replace whole URLs only: `old` must not be followed by more URL characters
          pat <- paste0(gsub("([][{}()+*^$|\\\\?.])", "\\\\\\1", old),
                        "(?![A-Za-z0-9/_%?#=&~+-]|\\.[A-Za-z0-9])")
          lines[i] <- gsub(pat, new, lines[i], perl = TRUE)
          changed <- TRUE
        }
      }
    }
    if (changed && !dry_run) writeLines(lines, f, useBytes = TRUE)
  }
  res <- if (length(out)) do.call(rbind, out) else
    data.frame(file = character(), line = integer(), old = character(),
               new = character(), exists = logical())
  n_map <- sum(!is.na(res$new))
  message(sprintf("%s: %d datavis.ca links; %d rewritten%s, %d left unmapped",
                  basename(dir), nrow(res), n_map, if (dry_run) " (dry run)" else "",
                  sum(is.na(res$new))))
  if (any(res$exists %in% FALSE))
    warning("Some new friendly.github.io/papers/ targets do not exist:\n  ",
            paste(unique(res$new[res$exists %in% FALSE]), collapse = "\n  "))
  invisible(res)
}
