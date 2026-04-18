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
The namespace is **`levlaz`**.

## Secrets (1Password)

Both local and CI flows pull secrets from the **`devops`** vault in
1Password, item **`levlaz-ci`**. The only secret stored directly in
CircleCI is the bootstrap `OP_SERVICE_ACCOUNT_TOKEN`; everything else
(`CIRCLE_TOKEN`, `GITHUB_TOKEN`) is fetched at job-time via the
[`onepassword/secrets`](https://circleci.com/developer/orbs/orb/onepassword/secrets)
orb.

References live in [`.env.1password`](./.env.1password) (safe to commit —
these are references, not values).

### Local

Prereqs: [`op` CLI](https://developer.1password.com/docs/cli/get-started/)
signed in with access to the `devops` vault.

```bash
# Run any command with secrets injected from 1Password:
./scripts/with-secrets.sh circleci orb publish ...

# Or drop into a shell that has CIRCLE_TOKEN / GITHUB_TOKEN set:
./scripts/with-secrets.sh bash
```

Under the hood this is just `op run --env-file=.env.1password -- <cmd>`.

### CI

One-time setup in CircleCI:

1. Create a 1Password [Service Account](https://developer.1password.com/docs/service-accounts/)
   with read access to the `devops` vault.
2. Create a CircleCI **context** named `orb-publishing` and add a single
   env var: `OP_SERVICE_ACCOUNT_TOKEN` = the service-account token.

At job time, the publish step's `pre-steps` install `op` and export
`CIRCLE_TOKEN` + `GITHUB_TOKEN` from the vault into the job env before
`orb-tools/publish` runs.

## Before you push

- [ ] Claim each new orb once: `circleci orb create levlaz/<orb-name>`.
- [ ] Create the `orb-publishing` context in CircleCI with
  `OP_SERVICE_ACCOUNT_TOKEN`.

## References

- [CircleCI Orb Author Intro](https://circleci.com/docs/orb-author-intro/)
- [Orb Authoring Best Practices](https://circleci.com/docs/orbs/author/orbs-best-practices/)
- [Orb-Template repo](https://github.com/CircleCI-Public/Orb-Template)
- [path-filtering orb](https://circleci.com/developer/orbs/orb/circleci/path-filtering)
- [orb-tools orb](https://circleci.com/developer/orbs/orb/circleci/orb-tools)
