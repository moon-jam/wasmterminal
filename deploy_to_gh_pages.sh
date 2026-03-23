#!/bin/bash
set -e

# Ensure we are in the my_wasmterminal directory
cd "$(dirname "$0")"

echo "Replacing symlinks in site/ with real files temporarily..."
cd site
cp -L vmlinux_wasm64_nommu.wasm tmp_vmlinux
cp -L initramfs_wasm64_nommu.cpio.gz tmp_initrd
rm vmlinux_wasm64_nommu.wasm initramfs_wasm64_nommu.cpio.gz
mv tmp_vmlinux vmlinux_wasm64_nommu.wasm
mv tmp_initrd initramfs_wasm64_nommu.cpio.gz
cd ..

echo "Setting up gh-pages deployment..."
git fetch origin || true
git branch -D gh-pages || true

# Copy site contents to a temp directory to survive the git rm
mkdir -p /tmp/gh-pages-deploy
cp -r site/* /tmp/gh-pages-deploy/

git checkout --orphan gh-pages
git rm -rf . > /dev/null

cp -r /tmp/gh-pages-deploy/* .
rm -rf /tmp/gh-pages-deploy

echo "Committing real Wasm binaries to gh-pages..."
git add -f *
git commit -m "Deploy to GitHub Pages"

echo "Pushing gh-pages branch to origin..."
git push origin gh-pages:gh-pages --force

echo "Restoring local workspace..."
git checkout -f migrate-wasm-7.0

# Restore the symlinks
cd site
rm -f vmlinux_wasm64_nommu.wasm initramfs_wasm64_nommu.cpio.gz
ln -s ../../linux-wasm/workspace/install/kernel-wasm64_nommu/vmlinux.wasm vmlinux_wasm64_nommu.wasm
ln -s ../../linux-wasm/workspace/install/initramfs-wasm64_nommu/initramfs.cpio.gz initramfs_wasm64_nommu.cpio.gz
cd ..

echo "Deployment complete! GitHub Pages will build from the gh-pages branch."
