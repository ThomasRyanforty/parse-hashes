#!/bin/bash
# extract-hashes.sh
# Usage: ./extract-hashes.sh <jsonfile>
# Example: ./extract-hashes.sh wd.json

INPUT="$1"
if [[ -z "$INPUT" || ! -f "$INPUT" ]]; then
  echo "Usage: $0 <jsonfile>"
  exit 1
fi

RAW=$(mktemp)
SALTED=$(mktemp)
UNSALTED=$(mktemp)

# Step 1. Extract all emails and usernames
jq -r '.. | .email_address? // empty' "$INPUT" | sort -u >> emails.txt
sort -u emails.txt -o emails.txt

jq -r '.. | .email_address? // empty' "$INPUT" | sed -n 's/@.*//p' | sort -u >> usernames.txt
sort -u usernames.txt -o usernames.txt

# Step 2. Flatten password fields and attach salts if present
jq -r '
  .. | objects
  | {p1: .password, p2: .password2, p3: .password3, salt: .salt}
  | . as $o
  | [.p1,.p2,.p3]
  | map(select(. != null and . != "\\N" and . != ""))
  | .[]
  | if $o.salt != null and $o.salt != "\\N" and $o.salt != ""
    then . + ":" + $o.salt
    else . end
  ' "$INPUT" > "$RAW"

# Step 3. Split salted vs unsalted
grep ':' "$RAW" > "$SALTED"
grep -v ':' "$RAW" > "$UNSALTED"

# Step 4. Classify unsalted
grep -E '^[[:xdigit:]]{32}$'   "$UNSALTED" >> md5_list.txt
grep -E '^[[:xdigit:]]{40}$'   "$UNSALTED" >> sha1_list.txt
grep -E '^[[:xdigit:]]{64}$'   "$UNSALTED" >> sha256_list.txt
grep -E '^[[:xdigit:]]{128}$'  "$UNSALTED" >> sha512_list.txt
grep -E '^\$2[aby]\$[0-9]{2}\$[./A-Za-z0-9]{53}$' "$UNSALTED" >> bcrypt_list.txt

grep -v -f <(cat md5_list.txt sha1_list.txt sha256_list.txt sha512_list.txt bcrypt_list.txt 2>/dev/null) \
  "$UNSALTED" >> plaintext_list.txt

# Step 5. Classify salted by hash length
awk -F: '{print $1":"$2}' "$SALTED" | grep -E '^[[:xdigit:]]{32}:'   >> md5_salted.txt
awk -F: '{print $1":"$2}' "$SALTED" | grep -E '^[[:xdigit:]]{40}:'   >> sha1_salted.txt
awk -F: '{print $1":"$2}' "$SALTED" | grep -E '^[[:xdigit:]]{64}:'   >> sha256_salted.txt
awk -F: '{print $1":"$2}' "$SALTED" | grep -E '^[[:xdigit:]]{128}:'  >> sha512_salted.txt

# Step 6. Deduplicate all output files
for f in md5_list.txt sha1_list.txt sha256_list.txt sha512_list.txt bcrypt_list.txt plaintext_list.txt \
         md5_salted.txt sha1_salted.txt sha256_salted.txt sha512_salted.txt emails.txt usernames.txt; do
  if [[ -f "$f" ]]; then
    sort -u "$f" -o "$f"
  fi
done

# Cleanup temps
rm -f "$RAW" "$SALTED" "$UNSALTED"

# Step 7. Print counts
echo "Extraction complete for $INPUT. Counts:"
for f in emails.txt usernames.txt md5_list.txt sha1_list.txt sha256_list.txt sha512_list.txt bcrypt_list.txt plaintext_list.txt \
         md5_salted.txt sha1_salted.txt sha256_salted.txt sha512_salted.txt; do
  if [[ -s "$f" ]]; then
    echo "  $(wc -l < "$f")  $f"
  fi
done
