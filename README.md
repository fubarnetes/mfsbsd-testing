# mfsbsd-testing
Testing MFSBSD image

# Running

```
qemu-system-x86_64 \
	-serial mon:stdio -nographic \
	-boot d -cdrom mfsbsd/mfsbsd-12.0-STABLE-amd64.iso \
	-m 5g \
	-net user,hostfwd=tcp::10022-:22 -net nic
```

# SSH
The SSH Keys in the `keys` directory allow sshing into the mfsbsd image. *THESE KEYS SHOULD NOT BE USED ANYWHERE ELSE*.

```
ssh -i keys/id_ed25519 -p 10022 root@localhost
```

# Building

Requirements
- FreeBSD 10 or later for mfsbsd
- Packages: `git`, `curl`, `jq`

```sh
#!/bin/sh
pkg install -y git curl jq
git clone https://github.com/fubarnetes/mfsbsd-testing
cd mfsbsd-testing
export GITHUB_TOKEN = <your personal access token>
./build.sh
```

If the current commit is tagged and a release exists on GitHub, the built ISO images are uploaded as assets.