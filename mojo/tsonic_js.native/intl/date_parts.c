#include "date_model.h"
#include "parts.h"
#include <stdio.h>

static const char *part_type(int32_t field) {
    switch (field) {
        case UDAT_ERA_FIELD: return "era";
        case UDAT_YEAR_FIELD: return "year";
        case UDAT_YEAR_NAME_FIELD: return "yearName";
        case UDAT_RELATED_YEAR_FIELD: return "relatedYear";
        case UDAT_MONTH_FIELD: case UDAT_STANDALONE_MONTH_FIELD: return "month";
        case UDAT_DATE_FIELD: return "day";
        case UDAT_HOUR_OF_DAY1_FIELD: case UDAT_HOUR_OF_DAY0_FIELD:
        case UDAT_HOUR1_FIELD: case UDAT_HOUR0_FIELD: return "hour";
        case UDAT_MINUTE_FIELD: return "minute";
        case UDAT_SECOND_FIELD: return "second";
        case UDAT_FRACTIONAL_SECOND_FIELD: return "fractionalSecond";
        case UDAT_DAY_OF_WEEK_FIELD: case UDAT_STANDALONE_DAY_FIELD:
        case UDAT_DOW_LOCAL_FIELD: return "weekday";
        case UDAT_AM_PM_FIELD: case UDAT_AM_PM_MIDNIGHT_NOON_FIELD:
        case UDAT_FLEXIBLE_DAY_PERIOD_FIELD: return "dayPeriod";
        case UDAT_TIMEZONE_FIELD: case UDAT_TIMEZONE_RFC_FIELD:
        case UDAT_TIMEZONE_GENERIC_FIELD: case UDAT_TIMEZONE_SPECIAL_FIELD:
        case UDAT_TIMEZONE_LOCALIZED_GMT_OFFSET_FIELD:
        case UDAT_TIMEZONE_ISO_FIELD: case UDAT_TIMEZONE_ISO_LOCAL_FIELD: return "timeZoneName";
        case UDAT_TIME_SEPARATOR_FIELD: return "literal";
        default: return NULL;
    }
}

int tsonic_intl_date_parts(TsonicIntlResult *result, UFieldPositionIterator *positions) {
    TsonicIntlField fields[TSONIC_INTL_MAX_PARTS];
    size_t count = 0;
    int32_t start = 0, end = 0, field;
    while ((field = ufieldpositer_next(positions, &start, &end)) >= 0) {
        const char *type = part_type(field);
        if (type == NULL || count == TSONIC_INTL_MAX_PARTS) {
            result->failed = 1;
            snprintf(result->error, sizeof(result->error), "Native date fields exceed the selected source contract");
            return 0;
        }
        fields[count++] = (TsonicIntlField){ type, start, end };
    }
    return tsonic_intl_partition_fields(result, fields, count);
}
