#!/bin/bash
# termup-mini - minimal file uploader (85 lines vs 678 original)
#
# Uploads files to 5 free services with smart dual-upload strategy:
#   1. Probes 4 services in parallel to find fastest
#   2. Uploads to fastest service + Pixeldrain simultaneously
#   3. Pixeldrain always uploads (has hardcoded API key)
#
# Services: temp.sh, sendit.sh, gofile.io, filebin.net, pixeldrain.com
# Dependencies: curl (required), jq (optional - has grep fallback)
#
# Usage: termup-mini.sh FILE
#        termup-mini.sh --help

set -e

# Show help
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  echo "termup-mini - minimal file uploader"
  echo
  echo "Usage: $(basename "$0") FILE"
  echo
  echo "Uploads to fastest service + pixeldrain (dual upload strategy)"
  echo
  echo "Supported services:"
  echo "  • temp.sh      - Free, simple upload"
  echo "  • sendit.sh    - Free, anonymous upload"  
  echo "  • gofile.io    - Free, fast CDN"
  echo "  • filebin.net  - Free, pastebin-like"
  echo "  • pixeldrain   - API-based (always uploads)"
  echo
  echo "Requirements: curl (jq optional for JSON parsing)"
  exit 0
fi

API_KEY="840a67ce-0562-47d2-b61d-f63e5fed1675"
FILE="${1}"
[[ -z "$FILE" || ! -f "$FILE" ]] && { echo "Usage: $0 FILE (use --help for more info)" >&2; exit 1; }
FILENAME=$(basename "$FILE")

# JSON extractor: jq with grep fallback
json_get() {
  local key="$1" data="$2"
  if command -v jq >/dev/null 2>&1; then
    echo "$data" | jq -r ".data.$key // .$key // empty" 2>/dev/null
  else
    echo "$data" | grep -oP "(?<=\"$key\":\")[^\"]+" | head -1
  fi
}

# Upload functions (with progress bar)
upload_tempsh() { curl --progress-bar -F "file=@$FILE" https://temp.sh/upload; }
upload_senditsh() { curl --progress-bar -T "$FILE" https://sendit.sh; }
upload_gofile() {
  local tmpfile="/tmp/termup-gofile-$$"
  curl --progress-bar -F "file=@$FILE" https://upload.gofile.io/uploadfile -o "$tmpfile"
  local url=$(json_get downloadPage "$(cat "$tmpfile" 2>/dev/null)")
  rm -f "$tmpfile"
  echo "$url"
}
upload_filebin() {
  local bin="termup-$(date +%s)-$$"
  local tmpfile="/tmp/termup-filebin-$$"
  curl --progress-bar --data-binary "@$FILE" -H "filename: $FILENAME" -H "bin: $bin" \
    https://filebin.net/ -o "$tmpfile"
  rm -f "$tmpfile"
  echo "https://filebin.net/$bin"
}
upload_pixeldrain() {
  local tmpfile="/tmp/termup-pixeldrain-$$"
  curl --progress-bar -T "$FILE" -u ":$API_KEY" https://pixeldrain.com/api/file/ -o "$tmpfile"
  local id=$(json_get id "$(cat "$tmpfile" 2>/dev/null)")
  rm -f "$tmpfile"
  [[ -n "$id" ]] && echo "https://pixeldrain.com/u/$id"
}

# Probe services (parallel) to find fastest
echo "Uploading: $FILE"
probe_file="/tmp/termup-probe-$$"
> "$probe_file"

for service in tempsh senditsh gofile filebin; do
  (
    case "$service" in
      tempsh) url="https://temp.sh/" ;;
      senditsh) url="https://sendit.sh/" ;;
      gofile) url="https://upload.gofile.io/" ;;
      filebin) url="https://filebin.net/" ;;
    esac
    start=$(date +%s%N 2>/dev/null || date +%s000000000)
    if curl -sS --head --connect-timeout 3 --max-time 5 "$url" >/dev/null 2>&1; then
      elapsed=$(($(date +%s%N 2>/dev/null || date +%s000000000) - start))
      echo "$service:$elapsed" >> "$probe_file"
    fi
  ) &
done
wait

# Find fastest service
fastest=$(sort -t: -k2 -n "$probe_file" 2>/dev/null | head -1 | cut -d: -f1)
rm -f "$probe_file"
[[ -z "$fastest" ]] && fastest="tempsh"

# Upload to fastest + pixeldrain
echo
fastest_success=0
pixeldrain_success=0

echo "$fastest:"
if url=$(upload_$fastest); then
  echo "$fastest: $url"
  fastest_success=1
else
  echo "$fastest: failed" >&2
fi

echo
echo "pixeldrain:"
if url=$(upload_pixeldrain); then
  echo "pixeldrain: $url"
  pixeldrain_success=1
else
  echo "pixeldrain: failed" >&2
fi

[[ $fastest_success -eq 1 || $pixeldrain_success -eq 1 ]] && exit 0 || exit 1
