# termup

Minimal file uploader - 126 lines of bash that uploads to 5 services with progress bars.

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

```bash
termup myfile.zip
```

Output:
```
Uploading: myfile.zip

gofile:
######################################################################## 100.0%
gofile: https://gofile.io/d/abc123

pixeldrain:
######################################################################## 100.0%
pixeldrain: https://pixeldrain.com/u/xyz789
```

## Features

- 126 lines of bash
- Uploads to 5 services: temp.sh, sendit.sh, gofile.io, filebin.net, pixeldrain
- Smart dual-upload (fastest service + pixeldrain for redundancy)
- Real-time progress bars
- Parallel service probing
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
