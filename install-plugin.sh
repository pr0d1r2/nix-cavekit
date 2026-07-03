# shellcheck shell=bash
# $out is provided by the nix build sandbox
# shellcheck disable=SC2154

missing=0
for path in plugin.json FORMAT.md; do
  if [ ! -f "$path" ]; then
    echo "error: expected upstream file not found: $path" >&2
    missing=1
  fi
done
for path in commands skills .claude-plugin; do
  if [ ! -d "$path" ]; then
    echo "error: expected upstream directory not found: $path" >&2
    missing=1
  fi
done
if [ "$missing" -ne 0 ]; then
  exit 1
fi

mkdir -p "$out/commands" "$out/skills"
cp plugin.json "$out/"
cp FORMAT.md "$out/"
cp -r commands "$out/"
cp -r skills "$out/"
cp -r .claude-plugin "$out/"
