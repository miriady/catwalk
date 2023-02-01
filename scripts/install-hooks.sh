#!/bin/bash -aex
# Copyright © 2023  Miriady, catwalk authors
# Full license text is available in the LICENSE file

pre-commit install --hook-type pre-commit
pre-commit install --hook-type commit-msg
