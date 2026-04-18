# hello

A friendly `hello world` orb. Doubles as the scaffold template for every
other orb in this monorepo — copy `orbs/hello/` to `orbs/<new-name>/` (or
run `./scripts/new-orb.sh <new-name>` from the repo root) to start.

## Usage

```yaml
version: 2.1
orbs:
  hello: levlaz/hello@1.0.0
workflows:
  say-hello:
    jobs:
      - hello/hello:
          to: "CircleCI"
```

## Commands

### `greet`

Echo a greeting to the given recipient.

| Parameter | Type   | Default | Description       |
| --------- | ------ | ------- | ----------------- |
| `to`      | string | `World` | Hello to whom?    |

## Jobs

### `hello`

Checks out the project and runs `greet`.
