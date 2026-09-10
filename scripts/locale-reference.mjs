import { isDeepStrictEqual } from "node:util";

const dateFields = ["weekday", "year", "month", "day"];
const timeFields = ["dayPeriod", "hour", "minute", "second", "fractionalSecondDigits"];
const dateOperations = new Set(["date", "time", "datetime", "dateFormat"]);

export function canonicalIntlOptions(options) {
  if (options === undefined || options === null) return options;
  const result = { ...options };
  for (const key of ["calendar", "collation", "numberingSystem"]) {
    if (typeof result[key] === "string") {
      result[key] = new Intl.Locale("und", { [key]: result[key] })[key];
    }
  }
  return result;
}

export function referenceDate(entry) {
  const date = new Date(entry.value);
  if (Number.isNaN(date.getTime())) return "Invalid Date";
  const supplied = canonicalIntlOptions(entry.options);
  if (supplied === null) throw new TypeError("Date options cannot be null");
  const options = { ...supplied };
  if (entry.operation === "date" && options.timeStyle !== undefined ||
      entry.operation === "time" && options.dateStyle !== undefined) {
    throw new TypeError("Date and time prototype styles have distinct domains");
  }
  if (options.dateStyle === undefined && options.timeStyle === undefined) {
    const dateDefault = !dateFields.some((field) => options[field] !== undefined);
    const timeDefault = !timeFields.some((field) => options[field] !== undefined);
    const needsDefaults = entry.operation === "date" ? dateDefault :
      entry.operation === "time" ? timeDefault : dateDefault && timeDefault;
    if (needsDefaults) {
      if (entry.operation !== "time") {
        for (const field of ["year", "month", "day"]) options[field] = "numeric";
      }
      if (entry.operation !== "date") {
        for (const field of ["hour", "minute", "second"]) options[field] = "numeric";
      }
    }
  }
  return new Intl.DateTimeFormat(entry.locales, options).format(date);
}

function unicodeKeywords(tag) {
  const parts = tag.split("-");
  const start = parts.indexOf("u");
  const result = new Map();
  const privateUse = parts.indexOf("x");
  if (start === -1 || privateUse !== -1 && privateUse < start) return result;
  let index = start + 1;
  while (index < parts.length && parts[index].length !== 1) {
    const key = parts[index++];
    if (key.length !== 2) continue;
    const values = [];
    while (index < parts.length && parts[index].length > 2) values.push(parts[index++]);
    result.set(key, values.join("-"));
  }
  return result;
}

export function referenceResolvedLocale(entry, resolved, constructor) {
  const requested = Intl.getCanonicalLocales(entry.locales);
  const selected = constructor.supportedLocalesOf(requested, { localeMatcher: entry.options?.localeMatcher })[0];
  const baseName = new Intl.Locale(resolved.locale).baseName;
  if (selected === undefined) return baseName;
  const keywords = unicodeKeywords(selected);
  const additions = {};
  const options = canonicalIntlOptions(entry.options);
  const relevant = constructor === Intl.Collator
    ? [["co", "collation"], ["kn", "numeric"], ["kf", "caseFirst"]]
    : [["ca", "calendar"], ["nu", "numberingSystem"], ["hc", "hourCycle"]];
  for (const [key, property] of relevant) {
    if (!keywords.has(key)) continue;
    const raw = keywords.get(key);
    const requestedValue = property === "numeric" ? raw === "" || raw === "true" : raw;
    if (property === "hourCycle") {
      if (options?.hour12 === undefined && ["h11", "h12", "h23", "h24"].includes(raw) &&
          (options?.hourCycle === undefined || options.hourCycle === raw)) additions[property] = raw;
    } else if (requestedValue === resolved[property]) {
      additions[property] = requestedValue;
    }
  }
  return new Intl.Locale(baseName, additions).toString();
}

function dateLiteral(value) {
  return value.replace(/[\u00a0\u202f]/gu, " ");
}

export function equivalentLocaleResult(entry, expected, actual) {
  if (expected === actual) return true;
  if (expected === "!error" || actual === "!error") return false;
  const reference = JSON.parse(expected);
  const candidate = JSON.parse(actual);
  if (dateOperations.has(entry.operation) && typeof reference === "string" && typeof candidate === "string") {
    return dateLiteral(reference) === dateLiteral(candidate);
  }
  if (entry.operation === "dateParts" && Array.isArray(reference) && Array.isArray(candidate)) {
    const normalize = (part) => part.type === "literal" ? { ...part, value: dateLiteral(part.value) } : part;
    return isDeepStrictEqual(reference.map(normalize), candidate.map(normalize));
  }
  return false;
}
