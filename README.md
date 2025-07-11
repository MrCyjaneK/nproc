# nproc

> Can't we have the same basic tools on all operating systems?????

## Usage

```bash
$ ./nproc.sh
16
$ NPROC_SH_SHOW_ERROR_ON_FALLBACK=yes ./nproc.sh # assuming unsupported host
ERROR: nproc.sh failed to detect CPU count
$ ./nproc.sh # assuming unsupported host
1
```

Supports:
- Windows, cygwin, msys
- Linux - all
- MacOS
- *BSD