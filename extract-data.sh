#!/usr/bin/env bash
# AIModified:2026-05-29T14:50:19Z
set -euo pipefail

BASE_URL="https://d37ci6vzurychx.cloudfront.net/trip-data"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<EOF
Usage: $(basename "$0") YEAR MONTH [MONTH ...]

Download NYC TLC yellow taxi trip Parquet for one or more months into
Hive-style partition directories under this script's project root.

Examples:
  $(basename "$0") 2024 1
  $(basename "$0") 2024 01 02 03

Output layout:
  data/raw/tlc/yellow/year=YEAR/month=MM/yellow_tripdata_YEAR-MM.parquet
EOF
}

download_month() {
  local year="$1"
  local month="$2"
  local month_padded filename dest_dir dest_path source_url

  month_padded="$(printf '%02d' "$((10#$month))")"
  filename="yellow_tripdata_${year}-${month_padded}.parquet"
  dest_dir="${SCRIPT_DIR}/data/raw/tlc/yellow/year=${year}/month=${month_padded}"
  dest_path="${dest_dir}/${filename}"
  source_url="${BASE_URL}/${filename}"

  mkdir -p "$dest_dir"

  echo "Downloading ${source_url}"
  echo "         -> ${dest_path}"

  curl -L --fail --progress-bar -o "$dest_path" "$source_url"

  echo "Done. Saved $(du -h "$dest_path" | cut -f1) to:"
  echo "  ${dest_path}"
  echo
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -lt 2 ]]; then
  usage >&2
  exit 1
fi

YEAR="$1"
shift

if ! [[ "$YEAR" =~ ^[0-9]{4}$ ]]; then
  echo "Error: YEAR must be a four-digit year (e.g. 2024)." >&2
  exit 1
fi

for MONTH in "$@"; do
  if ! [[ "$MONTH" =~ ^[0-9]{1,2}$ ]] || ((10#$MONTH < 1 || 10#$MONTH > 12)); then
    echo "Error: MONTH must be between 1 and 12 (got '${MONTH}')." >&2
    exit 1
  fi
done

for MONTH in "$@"; do
  download_month "$YEAR" "$MONTH"
done

echo "All downloads complete."
