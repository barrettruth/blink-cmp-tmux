# Contributing

Development, issues, and pull requests happen on
[Forgejo](https://git.barrettruth.com/barrettruth/blink-cmp-tmux).

## Scope

blink-cmp-tmux is a compact tmux command completion source for blink.cmp. It is
not a tmux session manager, command runner, or completion framework.

## Pull Requests

Bug fixes and documentation fixes are welcome. AI-generated contributions are
not accepted.

For new behavior, open an issue first unless the change is small and already
fits the project's scope.

Behavior or configuration changes should update `README.md` and
`doc/blink-cmp-tmux.txt` when appropriate.

## Development

It is preferred to use the Nix development shell, which bundles all necessary
tools:

```sh
nix develop
```

## Checks

Run the local checks before opening a pull request:

```sh
nix develop --command just ci
```
