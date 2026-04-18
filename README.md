# Orbs

A personal monorepo of CircleCI orbs.

Each orb lives in its own directory under `orbs/<orb-name>/` and follows the
standard [CircleCI orb development kit](https://github.com/CircleCI-Public/Orb-Template)
layout (a `src/` tree that gets packed into a single `orb.yml` at build time).

## Layout

```
.
├── .circleci/
│   ├── config.yml            # setup pipeline — uses path-filtering to detect changed orbs
│   └── continue-config.yml   # continuation pipeline — lints, packs, tests, publishes each orb
├── orbs/
│   └── hello/                # sample orb — copy this to start a new one
│       ├── README.md
│       └── src/
│           ├── @orb.yml
│           ├── commands/
│           ├── jobs/
│           ├── executors/
│           ├── examples/
│           └── scripts/
├── scripts/
│   └── new-orb.sh            # scaffolds a new orb from the hello template
└── ...
```

## Adding a new orb

```bash
./scripts/new-orb.sh my-orb
```

Then edit `orbs/my-orb/src/@orb.yml` and wire a workflow for it in
`.circleci/continue-config.yml` by copying the `hello` block and renaming.

## How the CI pipeline works

This repo uses CircleCI's [dynamic configuration](https://circleci.com/docs/dynamic-config/)
via the [`path-filtering`](https://circleci.com/developer/orbs/orb/circleci/path-filtering)
orb, so only the orbs whose `src/` changed on a given commit are built and tested.

1. `setup: true` in `.circleci/config.yml` runs first.
2. `path-filtering/filter` compares the commit diff against path patterns
   and sets a boolean pipeline parameter per orb (e.g. `run-hello`).
3. Those parameters gate the per-orb workflows in `continue-config.yml`.
4. Each per-orb workflow runs `orb-tools/lint`, `orb-tools/pack`,
   `orb-tools/review`, `shellcheck/check`, a command smoke-test job, and —
   on a `v*.*.*` tag — `orb-tools/publish` to the CircleCI registry.

## Publishing

Publishing a production version is triggered by pushing a semver tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

Only the orb whose directory changed on that tagged commit is published.
A CircleCI **context** named `orb-publishing` is expected to provide
`CIRCLE_TOKEN` with `write` permission on your namespace.

## Before you push

- [ ] Replace `<namespace>` in `.circleci/continue-config.yml` with your
  CircleCI orb namespace (run `circleci namespace create <name> github <org>` if
  you don't have one yet).
- [ ] Claim each new orb once with `circleci orb create <namespace>/<orb-name>`.
- [ ] Create the `orb-publishing` context in the CircleCI UI and attach a
  `CIRCLE_TOKEN` env var.

## References

- [CircleCI Orb Author Intro](https://circleci.com/docs/orb-author-intro/)
- [Orb Authoring Best Practices](https://circleci.com/docs/orbs/author/orbs-best-practices/)
- [Orb-Template repo](https://github.com/CircleCI-Public/Orb-Template)
- [path-filtering orb](https://circleci.com/developer/orbs/orb/circleci/path-filtering)
- [orb-tools orb](https://circleci.com/developer/orbs/orb/circleci/orb-tools)
