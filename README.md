# parse-hashes
Bash utility for parsing large JSON credential datasets into organized, deduplicated text files containing usernames, email addresses, plaintext values, hashes, and salted hashes for authorized security testing and data analysis.
## GitHub Repository Description

Bash utility for parsing large JSON credential datasets into organized, deduplicated text files containing usernames, email addresses, plaintext values, hashes, and salted hashes for authorized security testing and data analysis.

# JSON Credential Parser

A lightweight Bash script for parsing large JSON files and separating credential-related data into organized `.txt` files.

The parser extracts and deduplicates:

* Email addresses
* Usernames
* MD5 hashes
* SHA-1 hashes
* SHA-256 hashes
* SHA-512 hashes
* bcrypt hashes
* Plaintext password values
* Salted MD5 hashes
* Salted SHA-1 hashes
* Salted SHA-256 hashes
* Salted SHA-512 hashes

## Prerequisites

Designed for **Linux, Kali Linux, Ubuntu, or WSL using Bash**.

Required utilities:

* `bash`
* `jq`
* `grep`
* `awk`
* `sed`
* `sort`
* `wc`
* `mktemp`

On Debian/Ubuntu/Kali:

```bash
# Update package metadata
sudo apt update

# Install jq; remaining utilities are normally included with the base OS
sudo apt install -y jq coreutils grep gawk sed

# Make the script executable
chmod +x parse-hashes.sh

# Parse a JSON dataset
./parse-hashes.sh example-domain-results.json
```

## Example Output

```text
Extraction complete for example-domain-results.json. Counts:
  961  emails.txt
  954  usernames.txt
  6    md5_list.txt
  31   sha1_list.txt
  2    sha256_list.txt
  26   bcrypt_list.txt
  73   plaintext_list.txt
  2    md5_salted.txt
  18   sha1_salted.txt
```

## Generated Files

The script writes results into the current working directory:

`emails.txt`, `usernames.txt`, `md5_list.txt`, `sha1_list.txt`, `sha256_list.txt`, `sha512_list.txt`, `bcrypt_list.txt`, `plaintext_list.txt`, `md5_salted.txt`, `sha1_salted.txt`, `sha256_salted.txt`, and `sha512_salted.txt`.

Existing output files are deduplicated using `sort -u`.

## Usage

```text
./parse-hashes.sh <json-file>
```

Example:

```text
./parse-hashes.sh leak-lookup-results.json
```

## Security Notice

This repository is intended for **authorized penetration testing, security assessments, credential exposure analysis, and defensive research**.

Credential datasets may contain highly sensitive information. Do not commit source JSON files, extracted credentials, plaintext passwords, hashes, salts, or customer-identifiable information to Git repositories.
