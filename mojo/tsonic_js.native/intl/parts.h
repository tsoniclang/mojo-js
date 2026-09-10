#ifndef TSONIC_JS_INTL_PARTS_H
#define TSONIC_JS_INTL_PARTS_H

#include "model.h"

#define TSONIC_INTL_MAX_PARTS 4096

typedef struct {
    const char *type;
    int32_t start;
    int32_t end;
} TsonicIntlField;

int tsonic_intl_partition_fields(TsonicIntlResult *result,
    const TsonicIntlField *fields, size_t count);

#endif
