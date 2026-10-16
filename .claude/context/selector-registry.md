# Selector Registry

| Target | Source Page | Selector Type | Selector / Path | Attribute | Fallback | Last Verified | Notes |
|---|---|---|---|---|---|---|---|
| `parish_notice_image_url` | `https://stlukesmarsdenpark.org.au/` | css | `.fl-module-modal-popup img` | `data-src`, then `src` (skipping `data:` placeholders) | no announcement button | 2026-10-16 | The home page's pop-up image (e.g. "Save the Date" poster), opened from the floating announcement button. `lib/features/parish/data/selectors/parish_home_selectors.dart` |
| `daily_reflections_url` | `https://www.risenlordcommunity.com/onyourknees` (third-party, ADR-0009) | css | `a[href]` whose text is exactly "Month YYYY" | `href` | the "On Our Knees" page | 2026-10-16 | Current month's Daily Readings & Reflections PDF, else the newest listed. `lib/features/resources/data/selectors/reflections_selectors.dart` |
| `pastoral_plan_url` | `https://stlukesmarsdenpark.org.au/` | css | `a[href]` whose text contains "pastoral plan" (case-insensitive) | `href` | `PastoralPlanConfig.pdfUrl` | 2026-10-16 | The home page's "Parish Pastoral Plan 2026-2028" button; matched by label, not styling classes. `lib/features/parish/data/selectors/parish_home_selectors.dart` |
| `pastoral_council_minutes_url` | `https://stlukesmarsdenpark.org.au/` | css | `a[href]` whose text contains "pastoral council" and "minutes" (case-insensitive) | `href` | `PastoralPlanConfig.councilMinutesUrl` | 2026-10-16 | The home page's "Parish Pastoral Council Meeting Minutes" button; matched by label, not styling classes. `lib/features/parish/data/selectors/parish_home_selectors.dart` |

**News/bulletins (05-news-tab):** intentionally has no entry here. Bulletin
data is extracted from the WordPress category RSS feed
(`https://stlukesmarsdenpark.org.au/category/bulletins/feed/`) via XML
element lookups + a regex on `content:encoded`/`description`
(`lib/features/news/data/parsers/rss_bulletin_parser.dart`), not CSS
selectors against a rendered page — see
`.claude/decisions/0004-news-rss-regex-vs-css-selector.md` for the rationale.
