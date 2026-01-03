# wplace-diffs

A repository used to release Wplace incremental backups derived from [wplace-archives](https://github.com/murolem/wplace-archives) and created using [wplace-tools](https://github.com/bczhc/wplace-tools)

## Download releases

- **[Initial backup](https://github.com/bczhc/wplace-diffs/releases/tag/initial)**: The starting point (full snapshot).
- **[2025-08](https://github.com/bczhc/wplace-diffs/releases/tag/2025-08)** / **[2025-09](https://github.com/bczhc/wplace-diffs/releases/tag/2025-09)** / **[2025-10](https://github.com/bczhc/wplace-diffs/releases/tag/2025-10)** / **[2025-11](https://github.com/bczhc/wplace-diffs/releases/tag/2025-11)** / **2025-12**
- **2026-01**

## Quick Use

Starting from `retrieve` version 1.4.0, SquashFS images can be read directly by `retrieve` - no mounting needed any more. Here's a quick example:

Say if one wants to extract chunk `(0, 0)` at snapshot point `2025-10-25T07-38-44.205Z`, just download the initial tarball, plus files under `2025-08`, `2025-09` and `2025-10`. First, please merge them:

```bash
cat 2025-08.sqfs.* > 2025-08.sqfs
cat 2025-09.sqfs.* > 2025-09.sqfs
cat 2025-10.sqfs.* > 2025-10.sqfs
```

Then, simply use `retrieve` to get the chunk image:

```bash
retrieve -c 0-0 -b initial-snapshot.tar -o out -t 2025-10-25T07-38-44.205Z \
  -d 2025-08.sqfs -d 2025-09.sqfs -d 2025-10.sqfs
```

The output chunk image is at `out/0-0/2025-10-25T07-38-44.205Z.png`.

For more CLI usages, please refer to [wplace-tools](https://github.com/bczhc/wplace-tools).

<details>
<summary>Old sections (using the mounting approach)</summary>

## Mount single month

The diff files are packed in SquashFS to enable a transparent compression support. Also, due to GitHub Release file size limitation, the downloaded files are split and should be merged back.

**1. Merge the split files**

```bash
# Example for the August release
cat 2025-08.sqfs.* > 2025-08.sqfs
```

**2. Mount squashfs**

```bash
mkdir -p mnt-2025-08
sudo mount -r 2025-08.sqfs mnt-2025-08
```

Now August `.diff` files are available under `mnt-2025-08`:

```console
❯ ls mnt-2025-08
2025-08-09T22-23-45.217Z.diff
2025-08-10T00-50-04.021Z.diff
2025-08-10T03-23-13.303Z.diff
...
```

## Mount several months

To mount multiple months, you do the above for each month and use OverlayFS to make them unified.

```bash
# say now you have mnt-2025-08, mnt-2025-09, mnt-2025-10
mkdir -p merged
sudo mount -t overlay overlay -o lowerdir=mnt-2025-08:mnt-2025-09:mnt-2025-10 merged
```

Now all the diff files can be accessed under `merged` folder.

There's a quick script to automate these all: [mount-all](https://github.com/bczhc/wplace-diffs/blob/main/scripts/mount-all). Just place it under the folder containing `*.sqfs` and run.

## Retrieve chunk image

An example for retrieving chunk (0, 0) at snapshot `2025-10-25T07-38-44.205Z`:

```bash
retrieve -c 0-0 -b initial-snapshot.tar -d merged -o out -t 2025-10-25T07-38-44.205Z
```

For more CLI usages, please refer to [wplace-tools](https://github.com/bczhc/wplace-tools).
</details>
