# name: Create Conventional Changelog
# on: [pull_request]

# jobs:
#   commitlint:
#     runs-on: ubuntu-latest
#     steps:
#       - name: Conventional Changelog Action
#         uses: TriPSs/conventional-changelog-action@v3
#         with:
#           github-token: ${{ secrets.github_token }}
#           git-message: 'chore(release): {version}'
#           git-branch: (${{ github.ref }})
#           preset: 'angular'
#           tag-prefix: 'v'
#           output-file: 'MY_CUSTOM_CHANGELOG.md'
#           release-count: '10'
#           version-file: './my_custom_version_file.json' // or .yml, .yaml, .toml
#           version-path: 'path.to.version'
#           skip-on-empty: 'false'
#           skip-version-file: 'false'
#           skip-commit: 'false'
#           git-branch: 'my-maintenance-branch'