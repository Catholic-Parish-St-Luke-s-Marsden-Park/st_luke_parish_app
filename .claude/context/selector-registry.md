# Selector Registry

| Target | Source Page | Selector Type | Selector / Path | Attribute | Fallback | Last Verified | Notes |
|---|---|---|---|---|---|---|---|

**News/bulletins (05-news-tab):** intentionally has no entry here. Bulletin
data is extracted from the WordPress category RSS feed
(`https://stlukesmarsdenpark.org.au/category/bulletins/feed/`) via XML
element lookups + a regex on `content:encoded`/`description`
(`lib/features/news/data/parsers/rss_bulletin_parser.dart`), not CSS
selectors against a rendered page — see
`.claude/decisions/0004-news-rss-regex-vs-css-selector.md` for the rationale.
