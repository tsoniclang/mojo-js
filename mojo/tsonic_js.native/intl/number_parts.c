#include "number_model.h"
#include "parts.h"
#include <stdio.h>
#include <unicode/unum.h>

static const char *part_type(int32_t field, int negative, int special) {
    switch (field) {
        case UNUM_INTEGER_FIELD: return special == 1 ? "nan" : special == 2 ? "infinity" : "integer";
        case UNUM_FRACTION_FIELD: return "fraction";
        case UNUM_DECIMAL_SEPARATOR_FIELD: return "decimal";
        case UNUM_GROUPING_SEPARATOR_FIELD: return "group";
        case UNUM_CURRENCY_FIELD: return "currency";
        case UNUM_PERCENT_FIELD: return "percentSign";
        case UNUM_SIGN_FIELD: return negative ? "minusSign" : "plusSign";
        case UNUM_EXPONENT_SYMBOL_FIELD: return "exponentSeparator";
        case UNUM_EXPONENT_SIGN_FIELD: return "exponentMinusSign";
        case UNUM_EXPONENT_FIELD: return "exponentInteger";
        case UNUM_COMPACT_FIELD: return "compact";
        default: return NULL;
    }
}

int tsonic_intl_number_parts(TsonicIntlResult *result,
    const UFormattedNumber *formatted, int negative, int special) {
    UErrorCode status = U_ZERO_ERROR;
    UFieldPositionIterator *positions = ufieldpositer_open(&status);
    if (U_SUCCESS(status) && positions != NULL) unumf_resultGetAllFieldPositions(formatted, positions, &status);
    if (U_FAILURE(status) || positions == NULL) {
        ufieldpositer_close(positions);
        result->failed = 1;
        snprintf(result->error, sizeof(result->error), "Unable to inspect native number fields");
        return 0;
    }
    TsonicIntlField fields[TSONIC_INTL_MAX_PARTS];
    size_t count = 0;
    int32_t start = 0, end = 0, field;
    while ((field = ufieldpositer_next(positions, &start, &end)) >= 0) {
        const char *type = part_type(field, negative, special);
        if (type == NULL || count == TSONIC_INTL_MAX_PARTS) {
            ufieldpositer_close(positions);
            result->failed = 1;
            snprintf(result->error, sizeof(result->error), "Native number fields exceed the selected source contract");
            return 0;
        }
        fields[count++] = (TsonicIntlField){ type, start, end };
    }
    ufieldpositer_close(positions);
    return tsonic_intl_partition_fields(result, fields, count);
}
