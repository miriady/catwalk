#!/bin/bash -aex
# Copyright © 2023 Silesian Aerospace Technologies, GCS Authors
# Full license text is available in the LICENSE file

pre-commit install --hook-type pre-commit
pre-commit install --hook-type commit-msg
