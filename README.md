# termup

Minimal file uploader - 126 lines of bash that uploads to 5 services with progress bars!

## Quick Install

```bash
wget -q https://raw.githubusercontent.com/rdndds/termup/main/termup-mini.sh -O ~/termup && chmod +x ~/termup && echo 'alias termup="~/termup"' >> ~/.bashrc && source ~/.bashrc && termup --help
```

## Features

- **126 lines** (81% smaller than original 678-line script)
- **5 services**: temp.sh, sendit.sh, gofile.io, filebin.net, pixeldrain
- **Smart dual-upload**: Fastest service + Pixeldrain for redundancy
- **Progress bars**: Real-time upload progress via curl
- **Parallel probing**: Finds fastest service automatically
- **Zero config**: Just run `termup yourfile.zip`
- **Works without jq**: Automatic grep fallback

## Usage

```bash
# Upload any file
termup myfile.zip

# Example output:
Uploading: myfile.zip

gofile:
######################################################################## 100.0%
gofile: https://gofile.io/d/abc123

pixeldrain:
######################################################################## 100.0%
pixeldrain: https://pixeldrain.com/u/xyz789
```

## How It Works

1. **Probes** 4 free services in parallel (3-5 seconds)
2. **Finds** the fastest responding service
3. **Uploads** to fastest + Pixeldrain simultaneously
4. **Shows** real-time progress bars
5. **Returns** 2 URLs for redundancy

## Documentation

- [Installation Guide](INSTALL.md) - Detailed installation instructions
- [Comparison](COMPARISON.md) - Feature comparison with original and Go version

## Requirements

- `curl` (required)
- `jq` (optional - has grep fallback)

## Supported Services

| Service       | Type | Max Size | Speed    |
|---------------|------|----------|----------|
| temp.sh       | Free | 5GB      | Fast     |
| sendit.sh     | Free | 500MB    | Fast     |
| gofile.io     | Free | Unlimited| Very Fast|
| filebin.net   | Free | No limit | Medium   |
| pixeldrain.com| API  | 20GB     | Fast     |

## Comparison

| Version       | Lines | Features                          |
|---------------|-------|-----------------------------------|
| Original bash | 678   | Complex, single upload            |
| Go v2         | 1,722 | Feature-rich, 6.3MB binary        |
| **termup**    | **126** | **Minimal, dual-upload, progress** |

## Why termup?

- **Simple**: No complex configuration, just works
- **Fast**: Parallel probing finds fastest service
- **Reliable**: Dual upload gives you 2 URLs for redundancy
- **Transparent**: Progress bars show upload status
- **Lightweight**: Just 3.5KB bash script
- **Portable**: Works on any Linux/macOS with curl

## Examples

```bash
# Upload an image
termup screenshot.png

# Upload a large video
termup ~/Videos/movie.mp4

# Upload an ISO file
termup ~/Downloads/ubuntu-24.04.iso

# Upload a compressed archive
termup backup.tar.gz
```

## Uninstall

```bash
rm ~/termup
sed -i '/alias termup=/d' ~/.bashrc
source ~/.bashrc
```

## License

MIT License - See [LICENSE](LICENSE) file

## Contributing

Contributions welcome! Feel free to:
- Report bugs
- Suggest features
- Submit pull requests
- Improve documentation

## Credits

Built on top of the original termup script. Simplified and optimized for speed and clarity.

## Star History

If you find this useful, please star the repo! 
