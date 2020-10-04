xv6-zig is zig port of xv6-riscv operating system.

```
zig build -Drelease-fast=true

qemu-system-riscv64 -machine virt -bios none -kernel zig-cache/bin/kernel -m 128M -smp 3 -nographic -drive file=fs.img,if=none,format=raw,id=x0 -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0
```
