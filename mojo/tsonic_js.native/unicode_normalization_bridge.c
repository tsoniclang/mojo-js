#include <unicode/unorm2.h>

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TSONIC_MAX_STRING_UNITS 16777216u

typedef struct {
    uint16_t *units;
    size_t length;
    char *error;
    int failed;
} TsonicUnicodeNormalizationResult;

static char *copy_error(const char *message) {
    size_t length = strlen(message);
    char *copy = (char *)malloc(length + 1u);
    if (copy == NULL) return NULL;
    memcpy(copy, message, length + 1u);
    return copy;
}

static TsonicUnicodeNormalizationResult *failure(const char *message) {
    TsonicUnicodeNormalizationResult *result =
        (TsonicUnicodeNormalizationResult *)calloc(1u, sizeof(*result));
    if (result != NULL) {
        result->error = copy_error(message);
        result->failed = 1;
    }
    return result;
}

static TsonicUnicodeNormalizationResult *icu_failure(UErrorCode status) {
    char message[160];
    int written = snprintf(
        message,
        sizeof(message),
        "Unicode normalization failed: %s",
        u_errorName(status)
    );
    return failure(
        written > 0 && (size_t)written < sizeof(message)
            ? message
            : "Unicode normalization failed"
    );
}

static const UNormalizer2 *normalizer_for(int form, UErrorCode *status) {
    switch (form) {
        case 1: return unorm2_getNFCInstance(status);
        case 2: return unorm2_getNFDInstance(status);
        case 3: return unorm2_getNFKCInstance(status);
        case 4: return unorm2_getNFKDInstance(status);
        default: return NULL;
    }
}

TsonicUnicodeNormalizationResult *tsonic_js_unicode_normalize(
    const uint16_t *source,
    size_t source_length,
    int form
) {
    if (source_length > TSONIC_MAX_STRING_UNITS ||
        source_length > INT32_MAX ||
        (source_length != 0u && source == NULL)) {
        return failure("Unicode normalization input exceeds its runtime contract");
    }
    UErrorCode status = U_ZERO_ERROR;
    const UNormalizer2 *normalizer = normalizer_for(form, &status);
    if (normalizer == NULL || U_FAILURE(status)) {
        return failure("Invalid Unicode normalization form");
    }
    int32_t required = unorm2_normalize(
        normalizer,
        (const UChar *)source,
        (int32_t)source_length,
        NULL,
        0,
        &status
    );
    if (required < 0 || (status != U_ZERO_ERROR && status != U_BUFFER_OVERFLOW_ERROR)) {
        return icu_failure(status);
    }
    TsonicUnicodeNormalizationResult *result =
        (TsonicUnicodeNormalizationResult *)calloc(1u, sizeof(*result));
    if (result == NULL) return NULL;
    result->length = (size_t)required;
    if (required == 0) return result;
    result->units = (uint16_t *)malloc((size_t)required * sizeof(uint16_t));
    if (result->units == NULL) {
        free(result);
        return failure("Unable to allocate normalized Unicode string");
    }
    status = U_ZERO_ERROR;
    int32_t written = unorm2_normalize(
        normalizer,
        (const UChar *)source,
        (int32_t)source_length,
        (UChar *)result->units,
        required,
        &status
    );
    if (U_FAILURE(status) || written != required) {
        free(result->units);
        free(result);
        return icu_failure(status);
    }
    return result;
}

const uint16_t *tsonic_js_unicode_normalize_units(
    const TsonicUnicodeNormalizationResult *result
) {
    return result == NULL ? NULL : result->units;
}

size_t tsonic_js_unicode_normalize_length(
    const TsonicUnicodeNormalizationResult *result
) {
    return result == NULL ? 0u : result->length;
}

const char *tsonic_js_unicode_normalize_error(
    const TsonicUnicodeNormalizationResult *result
) {
    return result == NULL ? NULL : result->error;
}

int tsonic_js_unicode_normalize_failed(
    const TsonicUnicodeNormalizationResult *result
) {
    return result == NULL || result->failed;
}

void tsonic_js_unicode_normalize_result_free(
    TsonicUnicodeNormalizationResult *result
) {
    if (result == NULL) return;
    free(result->units);
    free(result->error);
    free(result);
}
