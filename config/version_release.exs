import Config

config :version_release,
  tag_prefix: "v",
  hex_publish: true,
  changelog: %{
    creation: :manual,
    minor_patterns: ["added", "changed"],
    major_patterns: ["breaking"],
    replacements: [
      %{
        file: "CHANGELOG.md",
        type: :changelog,
        patterns: [
          %{search: "Unreleased", replace: "{{version}}", type: :unreleased},
          %{search: "...HEAD", replace: "...{{tag_name}}", global: false},
          %{search: "ReleaseDate", replace: "{{date}}"},
          %{
            search: "<!-- next-header -->",
            replace: "<!-- next-header -->\n\n## [Unreleased] - ReleaseDate",
            global: false
          },
          %{
            search: "<!-- next-url -->",
            replace:
              "<!-- next-url -->\n[Unreleased]: https://github.com/wois-org/papelillo/compare/{{tag_name}}...HEAD",
            global: false
          }
        ]
      }
    ]
  },
  commit_message: "[skip ci][version_release] {{message}}"
