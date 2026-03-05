# termup

Minimal file uploader - 196 lines of bash that uploads to 5 services with progress bars.

## Install

```bash
wget -q https://raw.githubusercontent.com/rdndds/termup/main/termup.sh -O ~/termup && chmod +x ~/termup && echo 'alias termup="~/termup"' >> ~/.bashrc && source ~/.bashrc && termup --help
```

**With curl:**
```bash
curl -fsSL https://raw.githubusercontent.com/rdndds/termup/main/termup.sh -o ~/termup && chmod +x ~/termup && echo 'alias termup="~/termup"' >> ~/.bashrc && source ~/.bashrc && termup --help
```

**Zsh users:** Replace `~/.bashrc` with `~/.zshrc`

## Usage

**Basic upload (automatic fastest service + pixeldrain):**
```bash
termup myfile.zip
```

**Select service manually:**
```bash
termup --select myfile.zip
```

### Example Output

**Normal mode:**
```
Uploading: myfile.zip

gofile:
######################################################################## 100.0%
gofile: https://gofile.io/d/abc123

pixeldrain:
######################################################################## 100.0%
pixeldrain: https://pixeldrain.com/u/xyz789
```

**Select mode:**
```
Uploading: myfile.zip

Available services:
  1) gofile     (342ms) (fastest)
  2) senditsh   (521ms)
  3) temp.sh    (687ms)
  4) filebin    (timeout)
  *) pixeldrain  (always included)

Select service (1-4, or Enter for fastest): 2

senditsh:
######################################################################## 100.0%
senditsh: https://sendit.sh/abc123

pixeldrain:
######################################################################## 100.0%
pixeldrain: https://pixeldrain.com/u/xyz789
```

## Features

- 196 lines of bash
- Uploads to 5 services: temp.sh, sendit.sh, gofile.io, filebin.net, pixeldrain
- Smart dual-upload (fastest service + pixeldrain for redundancy)
- Manual service selection with `--select` flag
- Real-time progress bars
- Parallel service probing with timing display
- Works without jq (automatic grep fallback)
- Zero configuration

## Requirements

- `curl` (required)
- `jq` (optional)

## Uninstall

```bash
rm ~/termup && sed -i '/alias termup=/d' ~/.bashrc && source ~/.bashrc
```

## License

MIT
