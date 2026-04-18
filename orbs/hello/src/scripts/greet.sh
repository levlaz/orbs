#!/bin/bash
# Using `circleci env subst` so the `to` string parameter can accept an
# env var reference (e.g. "${MY_NAME}") and still work for plain strings.
# https://circleci.com/docs/orbs-best-practices/#accepting-parameters-as-strings-or-environment-variables
TO=$(circleci env subst "${PARAM_TO}")
echo "Hello ${TO:-World}!"
