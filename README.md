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

`date/` separates timestamp arithmetic, ISO/display parsing, ICU timezone
queries, formatting and the mutable Date value. UTC arithmetic does not consult
the OS. Local operations use the host timezone and the pinned ICU transition
database. Omitted setter arguments retain their old fields; supplied undefined
or NaN invalidates the date. Default source strings remain native strings.

## Development

```bash
npm test
```
