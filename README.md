# Mojo JavaScript Surface

Opt-in JavaScript semantics for the Tsonic Mojo target.

Native Mojo strings, collections, and numbers remain the default target
representations. This package is loaded only when the JavaScript source
surface is selected.

## Organization

Regular-expression declarations live in `mojo/tsonic_js/regexp/`: `core.mojo`
owns the public operation objects, `engine/` owns the native bridge, `protocols/`
owns callback invocation and replacement, and `results/` owns result values and
decoding. The root `tsonic_js` exports remain the consumer entrypoint. Native
strings and explicitly requested `JsString` values retain separate contracts.
The existing native and JavaScript differential proofs exercise both through
that public entrypoint; architecture tests enforce the internal import boundary.

`value/` separates the closed value/node model, graph builder, graph copying,
constructors, structured cloning and tagged callback decoding. Representation
does not depend on those consumers. The `value` entrypoint preserves imports
used by the JSON, collection, RegExp and Node runtimes.

Closed values can also retain unsigned-byte views. Backing storage, subrange and
object identity remain distinct; copying a view is not copying its bytes.
An owning provider may supply an exact nominal brand and selected presentation
callbacks. This does not add provider names or native-object reflection to JS.
For example, Node supplies Buffer's brand and JSON presentation; the JS runtime
owns the unsigned-byte data representation only.

Structured cloning preserves shared backing between cloned views but never
shares that backing with the source. It strips producer-specific presentation
and returns plain unsigned-byte views. The strict version-3 transport records
each backing store once and validates view bounds before exposing a result;
older transport versions reject. Byte storage/transport is capped at 16 MiB.
These additions are written but unverified in the current coding-only phase.

`date/` separates timestamp arithmetic, ISO/display parsing, ICU timezone
queries, formatting and the mutable Date value. UTC arithmetic does not consult
the OS. Local operations use the host timezone and the pinned ICU transition
database. Omitted setter arguments retain their old fields; supplied undefined
or NaN invalidates the date. Default source strings remain native strings.

`intl/` owns closed locale/options validation and ICU-backed casing, collation
and Date locale presentation. Date styles, components, calendars, numbering
systems, time zones and hour-cycle controls remain independent inputs. The
basic format matcher scores ICU's available formats; best fit delegates to its
pattern generator. Regional hour preferences come from ICU's CLDR data rather
than country-name branches. Invalid Date returns before locale/options access.
These Date methods do not imply support for every Intl constructor API.

Numeric locale presentation uses ICU NumberFormatter with explicit digit,
currency, grouping, sign, notation and rounding controls. Integral native
carriers enter through ICU's exact decimal input rather than Float64, preserving
64-bit values. Floating carriers retain signed zero and non-finite values.
No formatter operation changes the source arithmetic carrier or requires the
caller to adopt a JS string representation.

## Development

```bash
npm test
```
