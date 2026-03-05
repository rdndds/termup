#!/bin/bash
# termup - minimal file uploader (126+ lines vs 678 original)
#
# Uploads files to 5 free services with smart dual-upload strategy:
#   1. Probes 4 services in parallel to find fastest
#   2. Uploads to fastest service + Pixeldrain simultaneously
#   3. Pixeldrain always uploads (has hardcoded API key)
#
# Services: temp.sh, sendit.sh, gofile.io, filebin.net, pixeldrain.com
# Dependencies: curl (required), jq (optional - has grep fallback)
#
# Usage: termup [--select] FILE
#        termup --help

set -e

# Show help
show_help() {
  echo "termup - minimal file uploader"
  echo
  echo "Usage: $(basename "$0") [OPTIONS] FILE"
  echo
  echo "Options:"
  echo "  -s, --select   Show service selection menu after probing"
  echo "  -h, --help     Show this help message"
  echo
  echo "Uploads to fastest service + pixeldrain (dual upload strategy)"
  echo "With --select, you can choose which service to pair with pixeldrain"
  echo
  echo "Supported services:"
  echo "  temp.sh      - Free, simple upload"
  echo "  sendit.sh    - Free, anonymous upload"  
  echo "  gofile.io    - Free, fast CDN"
  echo "  filebin.net  - Free, pastebin-like"
  echo "  pixeldrain   - API-based (always uploads)"
  echo
  echo "Requirements: curl (jq optional for JSON parsing)"
}

# Parse arguments
SELECT_MODE=0
FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) show_help; exit 0 ;;
    -s|--select) SELECT_MODE=1; shift ;;
    -*) echo "Unknown option: $1" >&2; show_help; exit 1 ;;
    *) FILE="$1"; shift ;;
  esac
done

[[ -z "$FILE" || ! -f "$FILE" ]] && { echo "Usage: $(basename "$0") [--select] FILE (use --help for more info)" >&2; exit 1; }

API_KEY="840a67ce-0562-47d2-b61d-f63e5fed1675"
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
  curl --progress-bar -T "$FILE" -H "filename: $FILENAME" -H "bin: $bin" \
    https://filebin.net/$bin/ -o "$tmpfile"
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

# Find fastest service or show selection menu
if [[ $SELECT_MODE -eq 1 ]]; then
  echo
  echo "Available services:"
  
  # Read probe results and build menu
  services_available=()
  services_timing=()
  index=1
  
  while IFS=: read -r service elapsed; do
    elapsed_ms=$((elapsed / 1000000))
    fastest_mark=""
    [[ $index -eq 1 ]] && fastest_mark=" (fastest)"
    printf "  %d) %-10s (%dms)%s\n" "$index" "$service" "$elapsed_ms" "$fastest_mark"
    services_available+=("$service")
    services_timing+=("$elapsed_ms")
    ((index++))
  done < <(sort -t: -k2 -n "$probe_file" 2>/dev/null)
  
  # Show failed services
  for service in tempsh senditsh gofile filebin; do
    if ! grep -q "^$service:" "$probe_file" 2>/dev/null; then
      printf "  %d) %-10s (timeout)\n" "$index" "$service"
      services_available+=("$service")
      services_timing+=("timeout")
      ((index++))
    fi
  done
  
  echo "  *) pixeldrain  (always included)"
  echo
  
  # Get user selection
  read -p "Select service (1-${#services_available[@]}, or Enter for fastest): " choice
  
  # Validate and set selection
  if [[ -z "$choice" ]]; then
    fastest="${services_available[0]}"
    echo "Using fastest: $fastest"
  elif [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le "${#services_available[@]}" ]]; then
    fastest="${services_available[$((choice-1))]}"
    if [[ "${services_timing[$((choice-1))]}" == "timeout" ]]; then
      echo "Warning: Selected service timed out during probe, may fail" >&2
    fi
  else
    echo "Invalid selection, using fastest: ${services_available[0]}" >&2
    fastest="${services_available[0]}"
  fi
  
  rm -f "$probe_file"
else
  # Normal mode: use fastest automatically
  fastest=$(sort -t: -k2 -n "$probe_file" 2>/dev/null | head -1 | cut -d: -f1)
  rm -f "$probe_file"
  [[ -z "$fastest" ]] && fastest="tempsh"
fi

# Upload to selected/fastest + pixeldrain
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
