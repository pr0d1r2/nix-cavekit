# shellcheck shell=bash
# $installScript and $out are provided by the nix build sandbox
# shellcheck disable=SC2154

tmpdir=$(mktemp -d)
printf '%s\n' "$installScript" > "$tmpdir/test-install.sh"

if (cd "$tmpdir" && out="$tmpdir/test-out" bash test-install.sh) 2>"$tmpdir/stderr.log"; then
  echo "FAIL: install-plugin.sh should fail when no upstream paths exist" >&2
  exit 1
fi

for path in plugin.json FORMAT.md commands skills .claude-plugin; do
  if ! grep -q "$path" "$tmpdir/stderr.log"; then
    echo "FAIL: error output should mention missing path: $path" >&2
    exit 1
  fi
done

rm -rf "$tmpdir"
touch "$out"
