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

## Development

```bash
npm test
```
