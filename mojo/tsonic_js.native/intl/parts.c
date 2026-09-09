#include "parts.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int invalid(TsonicIntlResult *result, const char *message) {
    if (result != NULL) {
        free(result->parts);
        result->parts = NULL;
        result->part_count = 0;
        result->failed = 1;
        snprintf(result->error, sizeof(result->error), "%s", message);
    }
    return 0;
}

static int compare_positions(const void *left, const void *right) {
    int32_t first = *(const int32_t *)left;
    int32_t second = *(const int32_t *)right;
    return (first > second) - (first < second);
}

int tsonic_intl_partition_fields(TsonicIntlResult *result,
    const TsonicIntlField *fields, size_t count) {
    if (result == NULL || result->failed || result->parts != NULL ||
        result->length > TSONIC_INTL_MAX_UNITS || (result->length != 0 && result->units == NULL) || count > TSONIC_INTL_MAX_PARTS ||
        (count != 0 && fields == NULL)) {
        return invalid(result, "Invalid internationalization field inventory");
    }
    int32_t *boundaries = malloc((count * 2 + 2) * sizeof(*boundaries));
    if (boundaries == NULL) return invalid(result, "Unable to allocate field boundaries");
    boundaries[0] = 0;
    boundaries[1] = (int32_t)result->length;
    for (size_t index = 0; index < count; ++index) {
        const TsonicIntlField *field = &fields[index];
        if (field->type == NULL || field->type[0] == '\0' || strlen(field->type) >= sizeof(result->parts[0].type) || field->start < 0 ||
            field->end <= field->start || (size_t)field->end > result->length) {
            free(boundaries);
            return invalid(result, "Invalid native field position");
        }
        boundaries[index * 2 + 2] = field->start;
        boundaries[index * 2 + 3] = field->end;
    }
    size_t boundary_count = count * 2 + 2;
    qsort(boundaries, boundary_count, sizeof(*boundaries), compare_positions);
    result->parts = calloc(boundary_count, sizeof(*result->parts));
    if (result->parts == NULL) {
        free(boundaries);
        return invalid(result, "Unable to allocate formatted parts");
    }
    for (size_t boundary = 1; boundary < boundary_count; ++boundary) {
        int32_t start = boundaries[boundary - 1], end = boundaries[boundary];
        if (start == end) continue;
        const char *type = "literal";
        int32_t width = INT32_MAX;
        int conflict = 0;
        for (size_t index = 0; index < count; ++index) {
            const TsonicIntlField *field = &fields[index];
            if (field->start > start || field->end < end) continue;
            int32_t field_width = field->end - field->start;
            if (field_width == width && strcmp(type, field->type) != 0) {
                conflict = 1;
            }
            if (field_width < width) {
                type = field->type;
                width = field_width;
                conflict = 0;
            }
        }
        if (conflict) {
            free(boundaries);
            return invalid(result, "Conflicting native field classifications");
        }
        if (result->part_count != 0 &&
            strcmp(result->parts[result->part_count - 1].type, type) == 0) {
            result->parts[result->part_count - 1].length += (size_t)(end - start);
        } else {
            if (result->part_count == TSONIC_INTL_MAX_PARTS) {
                free(boundaries);
                return invalid(result, "Formatted parts exceed their finite budget");
            }
            TsonicIntlPart *part = &result->parts[result->part_count++];
            memcpy(part->type, type, strlen(type) + 1);
            part->start = (size_t)start;
            part->length = (size_t)(end - start);
        }
    }
    free(boundaries);
    return 1;
}

size_t tsonic_js_intl_part_count(const TsonicIntlResult *result) {
    return result == NULL || result->failed ? 0 : result->part_count;
}

const char *tsonic_js_intl_part_type(const TsonicIntlResult *result, size_t index) {
    return result == NULL || result->failed || index >= result->part_count ? NULL : result->parts[index].type;
}

size_t tsonic_js_intl_part_start(const TsonicIntlResult *result, size_t index) {
    return result == NULL || result->failed || index >= result->part_count ? SIZE_MAX : result->parts[index].start;
}

size_t tsonic_js_intl_part_length(const TsonicIntlResult *result, size_t index) {
    return result == NULL || result->failed || index >= result->part_count ? SIZE_MAX : result->parts[index].length;
}
