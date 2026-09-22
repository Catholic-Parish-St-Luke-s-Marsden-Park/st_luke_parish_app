/// App-wide Riverpod retry policy.
///
/// Riverpod 3.x retries a failing provider automatically unless a policy
/// is supplied: `ProviderContainer.defaultRetry` re-runs it up to 10 times
/// with exponential backoff (200ms doubling to a 6.4s ceiling — roughly
/// 38 seconds in total) for any failure that is not an `Error` or a
/// `ProviderException`. Every typed failure in this app implements
/// `Exception`, so all of them fall inside that default.
///
/// This app does not want that. Each feature's async surface already
/// renders an explicit error view with a "Try again" button, so a failure
/// should reach the user immediately and let them decide. Retrying
/// silently would leave them on a spinner for ~38s, and for the paid
/// OpenRouter call behind `saintOfTheDayProvider` it would also issue ten
/// more requests for failures that cannot succeed on retry — a revoked
/// key's 401, or a 429 that each attempt makes worse.
///
/// Returning `null` means "do not retry". Shared by `main.dart` and the
/// provider tests so production and test behaviour cannot drift apart.
Duration? noAutomaticRetry(int retryCount, Object error) => null;
