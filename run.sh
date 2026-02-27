#!/bin/bash

# === إعدادات عامة ===
QEMU_CMD="qemu-system-aarch64"
ROOT_IMG="root.ext4"
KERNEL_IMG="Image"
TAP_IF="tap0"

echo "🔍 Checking QEMU installation..."
if ! command -v $QEMU_CMD &>/dev/null; then
    echo "❌ QEMU not found!"
    echo "➡️ Please install qemu-system package:"
    echo "   sudo apt install qemu-system qemu-system-arm qemu-utils -y"
    exit 1
else
    echo "✅ QEMU found: $($QEMU_CMD --version | head -n1)"
fi

# === تحقق من وجود ملفات النظام ===
echo "🔍 Checking required files..."
if [[ ! -f "$ROOT_IMG" ]]; then
    echo "❌ Missing: $ROOT_IMG (root filesystem image)"
    exit 1
fi

if [[ ! -f "$KERNEL_IMG" ]]; then
    echo "❌ Missing: $KERNEL_IMG (Linux kernel image)"
    exit 1
fi

echo "✅ Found both $ROOT_IMG and $KERNEL_IMG"

# === إعداد واجهة tap0 ===
echo "🔍 Checking TAP interface..."
if ip link show "$TAP_IF" &>/dev/null; then
    echo "✅ TAP interface '$TAP_IF' already exists"
else
    echo "⚙️ Creating TAP interface '$TAP_IF'..."
    sudo ip tuntap add dev "$TAP_IF" mode tap || { echo "❌ Failed to create TAP interface"; exit 1; }
    sudo ip addr add 192.168.7.1/24 dev "$TAP_IF"
    sudo ip link set "$TAP_IF" up
    echo "✅ TAP interface '$TAP_IF' is ready"
fi

# === تشغيل QEMU ===
echo "🚀 Starting QEMU..."
$QEMU_CMD \
  -machine virt \
  -cpu cortex-a57 \
  -smp 4 \
  -m 4096 \
  -snapshot \
  -kernel "$KERNEL_IMG" \
  -append "root=/dev/vda rw console=ttyAMA0 mem=4096M ip=192.168.7.2::192.168.7.1:255.255.255.0::eth0:off:8.8.8.8 net.ifnames=0 swiotlb=0" \
  -drive id=disk0,file="$ROOT_IMG",if=none,format=raw \
  -device virtio-blk-pci,drive=disk0 \
  -device virtio-net-pci,netdev=net0,mac=52:54:00:12:34:02 \
  -netdev tap,id=net0,ifname="$TAP_IF",script=no,downscript=no \
  -object rng-random,filename=/dev/urandom,id=rng0 \
  -device virtio-rng-pci,rng=rng0 \
  -device virtio-gpu-pci \
  -device qemu-xhci \
  -device usb-tablet \
  -device usb-kbd \
  -display sdl,show-cursor=on \
  -serial mon:stdio
