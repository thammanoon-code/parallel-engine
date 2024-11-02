#/bin/bash

nix-build --version
test $? -eq 0 || { echo "Nix is not installed!"; exit 1; }

with_tests=false


while getopts 't' flag; do
  case "${flag}" in
    t) with_tests=true ;;
    *) break
       ;;
  esac
done

cp assembly/nix/macos-* .
export NIX_PATH=nixpkgs=https://github.com/nixOS/nixpkgs/archive/23.05.tar.gz

if [ "$with_tests" = true ]; then
  nix-build macos-static.nix --arg testing true
else
  nix-build macos-static.nix
fi

mkdir -p artifacts/lib
cp ./result-bin/bin/* artifacts/
test $? -eq 0 || { echo "No artifacts have been built..."; exit 1; }
chmod +x artifacts/*
rm -rf result-bin

nix-build macos-tonlib.nix

cp ./result/lib/libtonlibjson.dylib artifacts/
cp ./result/lib/libemulator.dylib artifacts/
cp ./result/lib/fift/* artifacts/lib/
cp -r ./result/share/ton/smartcont artifacts/
chmod -R +x artifacts
cd artifacts
sudo strip -xSX storage-daemon \
         storage-daemon-cli \
         blockchain-explorer \
         fift \
         tlbc \
         func \
         tolk \
         create-state \
         validator-engine-console \
         tonlib-cli \
         http-proxy \
         rldp-http-proxy \
         dht-server \
         lite-client \
         validator-engine \
         generate-random-id \
         adnl-proxy \
         libemulator.dylib \
         libtonlibjson.dylib
