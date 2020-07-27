package com.watchn.ui.util;

import lombok.extern.slf4j.Slf4j;
import reactor.util.retry.Retry;
import reactor.util.retry.RetryBackoffSpec;

import java.time.Duration;

@Slf4j
public class RetryUtils {
    public static RetryBackoffSpec apiClientRetrySpec(String description) {
        return Retry
                .backoff(3, Duration.ofSeconds(1))
                .doBeforeRetry(context -> log.warn("Retrying {}", description));
    }
}
