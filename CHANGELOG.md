# Changelog

## 0.4.0

- Support current Elixir and Erlang releases with Ecto 3.13+.
- Ignore virtual fields and schema metadata when updating seeds.
- Handle explicitly supplied associations with Ecto association changesets.
- Evaluate seed scripts with `Code.eval_file/1`, including repeated runs.
- Raise on failed inserts so seed commands cannot silently skip records.
- Require Elixir 1.15+; remove Ecto 1/2 support.
