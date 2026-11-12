#!/bin/sh

# Starts the docker compose stack used to run the smoke tests outside CDP.
#
# The Postgres schema is the Liquibase changelog in the waste-organisations
# repository. Unless WASTE_ORGANISATIONS_CHANGELOG points at a changelog folder,
# it is fetched here at the version of the image being tested.

set -e

REPOSITORY="https://github.com/DEFRA/waste-organisations.git"
CHECKOUT_DIR="$PWD/.waste-organisations"

if [ -z "$WASTE_ORGANISATIONS_CHANGELOG" ]; then
  # Releases are tagged with the image version; the latest image is built from main.
  if [ -z "$WASTE_ORGANISATIONS" ] || [ "$WASTE_ORGANISATIONS" = "latest" ]; then
    ref="main"
  else
    ref="$WASTE_ORGANISATIONS"
  fi

  echo "Fetching the waste-organisations changelog at $ref"
  rm -rf "$CHECKOUT_DIR"
  git clone --quiet --depth 1 --filter=blob:none --sparse --branch "$ref" "$REPOSITORY" "$CHECKOUT_DIR"
  git -C "$CHECKOUT_DIR" sparse-checkout set changelog

  WASTE_ORGANISATIONS_CHANGELOG="$CHECKOUT_DIR/changelog"
else
  echo "Using the changelog in $WASTE_ORGANISATIONS_CHANGELOG"
fi

if [ ! -f "$WASTE_ORGANISATIONS_CHANGELOG/db.changelog.xml" ]; then
  echo "db.changelog.xml is not found in $WASTE_ORGANISATIONS_CHANGELOG"
  exit 1
fi

export WASTE_ORGANISATIONS_CHANGELOG

docker compose up --wait --wait-timeout 300 -d --quiet-pull
