/// The descriptive `User-Agent` the app sends to the parish website. Its
/// firewall rejects generic HTTP clients, so every request to it identifies
/// the app and points back at the site.
const String parishAppUserAgent =
    'StLukesParishApp/1.0 (+https://stlukesmarsdenpark.org.au)';
