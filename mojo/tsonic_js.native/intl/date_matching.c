#include "date_model.h"
#include <limits.h>
#include <string.h>
#include <unicode/uenum.h>
#include <unicode/ustring.h>

enum {
    WEEKDAY, ERA, YEAR, MONTH, DAY, PERIOD, HOUR, MINUTE, SECOND, FRACTION, ZONE,
    FIELD_COUNT
};

static int text_width(int32_t width) {
    return width == 5 ? 2 : width == 4 ? 4 : 3;
}

static int pattern_fields(const UChar *pattern, int32_t length,
    int *fields, UChar *hour) {
    for (int index = 0; index < FIELD_COUNT; ++index) fields[index] = -1;
    *hour = 0;
    int quoted = 0;
    for (int32_t index = 0; index < length;) {
        UChar symbol = pattern[index++];
        if (symbol == '\'') {
            if (index < length && pattern[index] == '\'') ++index;
            else quoted = !quoted;
            continue;
        }
        if (quoted || !((symbol >= 'a' && symbol <= 'z') || (symbol >= 'A' && symbol <= 'Z'))) continue;
        int32_t width = 1;
        while (index < length && pattern[index] == symbol) { ++width; ++index; }
        int field = -1;
        int value = width == 2 ? 0 : 1;
        switch (symbol) {
            case 'E': field = WEEKDAY; value = text_width(width); break;
            case 'e': case 'c':
                if (width < 3) return 0;
                field = WEEKDAY; value = text_width(width); break;
            case 'G': field = ERA; value = text_width(width); break;
            case 'y': case 'u': case 'U': case 'r': field = YEAR; break;
            case 'M': case 'L': field = MONTH; if (width >= 3) value = text_width(width); break;
            case 'd': field = DAY; break;
            case 'B': case 'b': field = PERIOD; value = text_width(width); break;
            case 'h': case 'H': case 'K': case 'k': case 'j': field = HOUR; *hour = symbol; break;
            case 'm': field = MINUTE; break;
            case 's': field = SECOND; break;
            case 'S': if (width > 3) return 0; field = FRACTION; value = width - 1; break;
            case 'z': field = ZONE; value = width < 4 ? 1 : 2; break;
            case 'O': field = ZONE; value = width < 4 ? 3 : 4; break;
            case 'v': field = ZONE; value = width < 4 ? 5 : 6; break;
            case 'a': continue;
            default: return 0;
        }
        fields[field] = value;
    }
    return !quoted;
}

static int zone_penalty(int requested, int candidate) {
    if (requested == candidate) return 0;
    if (requested == 1 || requested == 5) {
        if (candidate == 3) return 1;
        if (candidate == 4) return 4;
        if (candidate == requested + 1) return 3;
    } else if (requested == 2 || requested == 6) {
        if (candidate == 4) return 1;
        if (candidate == 3) return 9;
        if (candidate == requested - 1) return 8;
    } else if (requested == 3 && candidate == 4) return 3;
    else if (requested == 4 && candidate == 3) return 8;
    return 120;
}

static int score_fields(const int *requested, const int *candidate) {
    int score = 0;
    for (int field = 0; field < FIELD_COUNT; ++field) {
        if (requested[field] == candidate[field]) continue;
        if (requested[field] == -1) score -= 20;
        else if (candidate[field] == -1) score -= 120;
        else if (field == ZONE) score -= zone_penalty(requested[field], candidate[field]);
        else {
            int delta = candidate[field] - requested[field];
            score -= delta >= 2 ? 6 : delta == 1 ? 3 : delta == -1 ? 6 : 8;
        }
    }
    return score;
}

int tsonic_intl_date_pattern_score(const UChar *requested, int32_t requested_length,
    const UChar *candidate, int32_t candidate_length, UErrorCode *status) {
    int requested_fields[FIELD_COUNT], candidate_fields[FIELD_COUNT];
    UChar ignored;
    if (!pattern_fields(requested, requested_length, requested_fields, &ignored) ||
        !pattern_fields(candidate, candidate_length, candidate_fields, &ignored)) {
        *status = U_ILLEGAL_ARGUMENT_ERROR;
        return INT_MIN;
    }
    return score_fields(requested_fields, candidate_fields);
}

typedef struct {
    int fields[FIELD_COUNT];
    UChar hour;
    UChar *pattern;
    int32_t capacity;
    int32_t length;
    int score;
} Match;

static void consider(Match *match, const UChar *pattern, int32_t length, UErrorCode *status) {
    if (length <= 0) return;
    int fields[FIELD_COUNT];
    UChar hour;
    if (!pattern_fields(pattern, length, fields, &hour) || (hour != 0 && hour != match->hour)) return;
    int score = score_fields(match->fields, fields);
    if (score <= match->score) return;
    if (length > match->capacity) {
        *status = U_BUFFER_OVERFLOW_ERROR;
        return;
    }
    memcpy(match->pattern, pattern, (size_t)length * sizeof(*pattern));
    match->length = length;
    match->score = score;
}

int32_t tsonic_intl_basic_date_pattern(UDateTimePatternGenerator *generator,
    const UChar *requested, int32_t requested_length, UChar hour,
    UChar *pattern, int32_t capacity, UErrorCode *status) {
    Match match = { .hour = hour, .pattern = pattern, .capacity = capacity, .score = INT_MIN };
    UChar ignored;
    if (!pattern_fields(requested, requested_length, match.fields, &ignored)) {
        *status = U_ILLEGAL_ARGUMENT_ERROR;
        return 0;
    }
    UEnumeration *skeletons = udatpg_openSkeletons(generator, status);
    const UChar *skeleton;
    int32_t length = 0;
    int count = 0;
    while (U_SUCCESS(*status) && skeletons != NULL &&
        (skeleton = uenum_unext(skeletons, &length, status)) != NULL) {
        if (++count > 4096) { *status = U_BUFFER_OVERFLOW_ERROR; break; }
        int32_t candidate_length = 0;
        const UChar *candidate = udatpg_getPatternForSkeleton(generator, skeleton, length, &candidate_length);
        if (candidate != NULL) consider(&match, candidate, candidate_length, status);
    }
    uenum_close(skeletons);
    const char *required[] = {
        "y", "MMMM", "MMMMd", "yMMMM", "yMMMMd", "yMMMMEEEEd",
        "jm", "jms", "yMMMMdjms", "yMMMMEEEEdjms",
        "yMd", "yMMMd", "yMMMEd", "yMdjm", "yMdjms", "yMMMEdjm", "yMMMEdjms",
        "jjmm", "jjmmss", "jmsSSS", "jmsz", "jmszzzz", "jmsO", "jmsOOOO", "jmsv", "jmsvvvv",
    };
    for (size_t index = 0; U_SUCCESS(*status) && index < sizeof(required) / sizeof(*required); ++index) {
        UChar input[128], candidate[2048];
        int32_t input_length = 0;
        u_strFromUTF8(input, 128, &input_length, required[index], -1, status);
        if (U_FAILURE(*status)) break;
        int32_t candidate_length = udatpg_getBestPatternWithOptions(generator, input, input_length,
            UDATPG_MATCH_HOUR_FIELD_LENGTH, candidate, 2048, status);
        if (U_SUCCESS(*status)) consider(&match, candidate, candidate_length, status);
    }
    if (U_SUCCESS(*status) && match.length == 0) *status = U_MISSING_RESOURCE_ERROR;
    return U_SUCCESS(*status) ? match.length : 0;
}
