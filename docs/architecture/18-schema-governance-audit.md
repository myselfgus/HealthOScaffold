# Schema governance audit

## Objective

Normalize how governance schemas are named and interpreted before heavy implementation begins.

## Audit result

The current governance schemas are consistent enough to proceed, with these explicit rules:

### 1. Naming split
- entity schemas may use Portuguese domain terms
- transport/runtime contracts may use English operational terms
- this is deliberate and not an error, as long as boundaries stay explicit

### 2. ID naming
- entity references should use `...Id`
- root identifiers should remain opaque/pseudonymous where possible
- direct identifiers must not appear as casual contract fields

### 3. Time naming
- domain/entity times prefer `...Em`, `validadeInicio`, `validadeFim`, `abertaEm`, `fechadaEm`
- transport/session contracts may preserve runtime-specific names already established

### 4. State vocabularies
- gate resolution values: `approved | rejected | cancelled`
- gate request status values: `pending | approved | rejected | cancelled`
- draft status values: `draft | awaiting_gate | approved | rejected | superseded`
- booleans remain explicit (`validado`, `revogado`, `ativo`)

### 5. Law-governance rule
- a deny/failure outcome is not represented as a silent absence of data
- authorization failure semantics belong in core service contracts, not only in schemas

## Follow-up recommendations

1. preserve Portuguese entity vocabulary in canonical entity schemas
2. preserve English operational vocabulary in runtime/provider/transport contracts where helpful
3. avoid renaming fields casually now that the scaffold has stabilized
4. add shared error envelope only after core service deny/failure semantics are finalized

## Conclusion

Schema vocabulary is sufficiently coherent for scaffold-hardening stage.
No destructive renaming pass is recommended at this time.
