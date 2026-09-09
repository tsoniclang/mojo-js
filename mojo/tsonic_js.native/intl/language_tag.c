#include "model.h"
#include <string.h>

typedef struct {
    char text[9];
    size_t length;
} Subtag;

static int alpha(const Subtag *part) {
    for (size_t index = 0; index < part->length; ++index) {
        if (part->text[index] < 'a' || part->text[index] > 'z') return 0;
    }
    return 1;
}

static int digits(const Subtag *part) {
    for (size_t index = 0; index < part->length; ++index) {
        if (part->text[index] < '0' || part->text[index] > '9') return 0;
    }
    return 1;
}

static int language(const Subtag *part) {
    return alpha(part) && (part->length == 2 || part->length == 3 ||
        (part->length >= 5 && part->length <= 8));
}

static int variant(const Subtag *part) {
    return part->length >= 5 || (part->length == 4 &&
        part->text[0] >= '0' && part->text[0] <= '9');
}

static int base_language(const Subtag *parts, size_t count, size_t *offset) {
    if (*offset >= count || !language(&parts[*offset])) return 0;
    ++*offset;
    if (*offset < count && parts[*offset].length == 4 && alpha(&parts[*offset])) ++*offset;
    if (*offset < count && ((parts[*offset].length == 2 && alpha(&parts[*offset])) ||
        (parts[*offset].length == 3 && digits(&parts[*offset])))) ++*offset;
    size_t variants = *offset;
    while (*offset < count && variant(&parts[*offset])) {
        for (size_t previous = variants; previous < *offset; ++previous) {
            if (strcmp(parts[previous].text, parts[*offset].text) == 0) return 0;
        }
        ++*offset;
    }
    return 1;
}

static int unicode_extension(const Subtag *parts, size_t begin, size_t end) {
    size_t offset = begin;
    while (offset < end && parts[offset].length >= 3) ++offset;
    while (offset < end) {
        const Subtag *key = &parts[offset++];
        if (key->length != 2 || key->text[1] < 'a' || key->text[1] > 'z') return 0;
        while (offset < end && parts[offset].length >= 3) ++offset;
    }
    return begin != end;
}

static int transformed_extension(const Subtag *parts, size_t begin, size_t end) {
    size_t offset = begin;
    if (offset < end && language(&parts[offset])) {
        if (!base_language(parts, end, &offset)) return 0;
    }
    while (offset < end) {
        const Subtag *key = &parts[offset++];
        if (key->length != 2 || key->text[0] < 'a' || key->text[0] > 'z' ||
            key->text[1] < '0' || key->text[1] > '9') return 0;
        size_t values = offset;
        while (offset < end && parts[offset].length >= 3) ++offset;
        if (values == offset) return 0;
    }
    return begin != end;
}

int tsonic_intl_valid_tag(const char *tag, size_t length) {
    if (tag == NULL || length == 0 || length > TSONIC_INTL_MAX_LOCALE) return 0;
    Subtag parts[TSONIC_INTL_MAX_LOCALE / 2 + 1];
    size_t count = 0;
    size_t offset = 0;
    while (offset < length) {
        Subtag *part = &parts[count++];
        part->length = 0;
        while (offset < length && tag[offset] != '-') {
            unsigned char character = (unsigned char)tag[offset++];
            if (character >= 'A' && character <= 'Z') character += 'a' - 'A';
            if (!((character >= 'a' && character <= 'z') ||
                  (character >= '0' && character <= '9')) || part->length == 8) return 0;
            part->text[part->length++] = (char)character;
        }
        if (part->length == 0) return 0;
        part->text[part->length] = '\0';
        if (offset < length && ++offset == length) return 0;
    }
    offset = 0;
    if (!base_language(parts, count, &offset)) return 0;
    unsigned char seen[128] = {0};
    while (offset < count) {
        const Subtag *singleton = &parts[offset++];
        if (singleton->length != 1) return 0;
        unsigned char key = (unsigned char)singleton->text[0];
        if (seen[key]) return 0;
        seen[key] = 1;
        if (key == 'x') return offset != count;
        size_t begin = offset;
        while (offset < count && parts[offset].length != 1) ++offset;
        if (begin == offset) return 0;
        if (key == 'u' && !unicode_extension(parts, begin, offset)) return 0;
        if (key == 't' && !transformed_extension(parts, begin, offset)) return 0;
    }
    return 1;
}
