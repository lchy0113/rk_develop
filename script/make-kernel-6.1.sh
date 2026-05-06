#!/usr/bin/env bash
set -euo pipefail

# Standalone kernel build helper executed inside kernel-6.1.
# - Uses Android product vars for consistent config/toolchain.
# - Builds out-of-tree into external directory.
# - Does not call Android make kernel target.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOP_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
KERNEL_SRC="$SCRIPT_DIR"

OUT_DIR="$TOP_DIR/build_linux-6.1"
TARGETS="Image modules dtbs"

JOBS="$(nproc)"
DO_CLEAN=0
DO_RECONFIG=0
DO_SYNC_MODULES=0

usage() {
  cat <<'EOF'
Usage: ./make-kernel-6.1.sh [options]

Options:
  -o, --out <dir>           External kernel output directory (default: build_linux-6.1)
  -t, --targets "..."       Kernel make targets (default: "Image modules dtbs")
  -j, --jobs <N>            Parallel jobs (default: nproc)
      --clean               Remove output directory before build
      --reconfig            Force defconfig regeneration
      --sync-modules        Sync built modules to PRODUCT_OUT/kdiwin_vendor_ramdisk_modules
    -h, --help                Show this help

Examples:
  ./make-kernel-6.1.sh
  ./make-kernel-6.1.sh --out build_linux-6.1 --reconfig
  ./make-kernel-6.1.sh --targets "Image" --jobs 16
  ./make-kernel-6.1.sh --sync-modules
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -o|--out)
      OUT_DIR="$2"
      shift 2
      ;;
    -t|--targets)
      TARGETS="$2"
      shift 2
      ;;
    -j|--jobs)
      JOBS="$2"
      shift 2
      ;;
    --clean)
      DO_CLEAN=1
      shift
      ;;
    --reconfig)
      DO_RECONFIG=1
      shift
      ;;
    --sync-modules)
      DO_SYNC_MODULES=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done



cd "$TOP_DIR"

TARGET_KERNEL_ARCH="$(get_build_var TARGET_KERNEL_ARCH)"
TARGET_KERNEL_DEFCONFIG="$(get_build_var TARGET_KERNEL_DEFCONFIG)"
TARGET_KERNEL_CONFIGS="$(get_build_var TARGET_KERNEL_CONFIGS)"
TARGET_KERNEL_CROSS_COMPILE_PREFIX="$(get_build_var TARGET_KERNEL_CROSS_COMPILE_PREFIX)"
TARGET_KERNEL_CLANG_PATH="$(get_build_var TARGET_KERNEL_CLANG_PATH)"
TARGET_KERNEL_EXTRA_ARGS="$(get_build_var TARGET_KERNEL_EXTRA_ARGS)"
TARGET_KERNEL_VERSION="$(get_build_var TARGET_KERNEL_VERSION)"
PRODUCT_OUT="$(get_build_var PRODUCT_OUT)"

if [[ -z "$TARGET_KERNEL_ARCH" || -z "$TARGET_KERNEL_DEFCONFIG" ]]; then
  echo "Error: Required kernel build vars are missing." >&2
  echo "  TARGET_KERNEL_ARCH=$TARGET_KERNEL_ARCH" >&2
  echo "  TARGET_KERNEL_DEFCONFIG=$TARGET_KERNEL_DEFCONFIG" >&2
  exit 1
fi


OUT_DIR_ABS="$(readlink -f "$OUT_DIR")"

# Android prebuilts clang toolchain
if [[ -z "${ANDROID_BUILD_TOP:-}" ]]; then
  ANDROID_BUILD_TOP="$TOP_DIR"
fi
export PATH="$ANDROID_BUILD_TOP/prebuilts/clang/host/linux-x86/clang-r530567/bin:$PATH"

ADDON_ARGS=""
if [[ "$TARGET_KERNEL_ARCH" == "arm64" ]]; then
  ADDON_ARGS="CROSS_COMPILE=aarch64-linux-gnu- LLVM=1 LLVM_IAS=1"
else
  ADDON_ARGS="CC=clang LD=ld.lld"
fi

if [[ "$DO_CLEAN" -eq 1 ]]; then
  echo "[clean] Removing $OUT_DIR_ABS"
  rm -rf "$OUT_DIR_ABS"
fi

mkdir -p "$OUT_DIR_ABS"

echo "=== Standalone Kernel Build ==="
echo "Kernel source    : $KERNEL_SRC"
echo "Kernel out       : $OUT_DIR_ABS"
echo "Arch             : $TARGET_KERNEL_ARCH"
echo "Defconfig        : $TARGET_KERNEL_DEFCONFIG"
echo "Config fragments : ${TARGET_KERNEL_CONFIGS:-<empty>}"
echo "Cross compile    : ${TARGET_KERNEL_CROSS_COMPILE_PREFIX:-<empty>}"
echo "Extra args       : ${TARGET_KERNEL_EXTRA_ARGS:-<empty>}"
echo "Targets          : $TARGETS"
echo "Jobs             : $JOBS"

MAKE_COMMON_ARGS=(
  -C "$KERNEL_SRC"
  O="$OUT_DIR_ABS"
  ARCH="$TARGET_KERNEL_ARCH"
)

if [[ -n "$TARGET_KERNEL_CROSS_COMPILE_PREFIX" ]]; then
  MAKE_COMMON_ARGS+=(CROSS_COMPILE="$TARGET_KERNEL_CROSS_COMPILE_PREFIX")
fi

echo "[build] Building kernel targets: $TARGETS"

if [[ ! -f "$OUT_DIR_ABS/.config" || "$DO_RECONFIG" -eq 1 ]]; then
  KCONFIG_DIR="$TOP_DIR/device/kdiwin/nova/common/kconfig"
  MERGE_KCONFIG_SH="$TOP_DIR/device/kdiwin/nova/common/mergekconfig.sh"
  KERNEL_CONFIG_DEFAULT="$KERNEL_SRC/arch/$TARGET_KERNEL_ARCH/configs/$TARGET_KERNEL_DEFCONFIG"
  KERNEL_CONFIG_RECOMMENDED="$KCONFIG_DIR/recommended.config"
  KERNEL_CONFIG_REQUIRED_SRC=("$KCONFIG_DIR/common.config")

  if [[ -f "$KCONFIG_DIR/$TARGET_KERNEL_ARCH.config" ]]; then
    KERNEL_CONFIG_REQUIRED_SRC+=("$KCONFIG_DIR/$TARGET_KERNEL_ARCH.config")
  fi
  if [[ -n "$TARGET_KERNEL_VERSION" && -f "$KCONFIG_DIR/$TARGET_KERNEL_VERSION/common.config" ]]; then
    KERNEL_CONFIG_REQUIRED_SRC+=("$KCONFIG_DIR/$TARGET_KERNEL_VERSION/common.config")
  fi
  if [[ -n "$TARGET_KERNEL_VERSION" && -f "$KCONFIG_DIR/$TARGET_KERNEL_VERSION/$TARGET_KERNEL_ARCH.config" ]]; then
    KERNEL_CONFIG_REQUIRED_SRC+=("$KCONFIG_DIR/$TARGET_KERNEL_VERSION/$TARGET_KERNEL_ARCH.config")
  fi

  KERNEL_CONFIG_REQUIRED="$OUT_DIR_ABS/.config.required"
  printf '%s\n' "${KERNEL_CONFIG_REQUIRED_SRC[@]}" > "$KERNEL_CONFIG_REQUIRED"

  KERNEL_CONFIG_SRC=("$KERNEL_CONFIG_DEFAULT" "$KERNEL_CONFIG_RECOMMENDED")
  if [[ -n "$TARGET_KERNEL_CONFIGS" ]]; then
    read -r -a TARGET_KERNEL_CONFIGS_ARR <<< "$TARGET_KERNEL_CONFIGS"
    KERNEL_CONFIG_SRC+=("${TARGET_KERNEL_CONFIGS_ARR[@]}")
  fi
  KERNEL_CONFIG_SRC+=("$KERNEL_CONFIG_REQUIRED")

  echo "[config] Merging kernel configs"
  for config in "${KERNEL_CONFIG_SRC[@]}"; do
    echo "- $config"
  done

  LLVM=1 LLVM_IAS=1 "$MERGE_KCONFIG_SH" \
    "$KERNEL_SRC" \
    "$OUT_DIR_ABS" \
    "$TARGET_KERNEL_ARCH" \
    "$TARGET_KERNEL_CROSS_COMPILE_PREFIX" \
    "${KERNEL_CONFIG_SRC[@]}"
fi

echo "[build] Building kernel targets: $TARGETS"
# shellcheck disable=SC2086
make -j"$JOBS" "${MAKE_COMMON_ARGS[@]}" $TARGET_KERNEL_EXTRA_ARGS $ADDON_ARGS $TARGETS

KERNEL_IMAGE_PATH="$OUT_DIR_ABS/arch/$TARGET_KERNEL_ARCH/boot/Image"
if [[ -f "$KERNEL_IMAGE_PATH" ]]; then
  echo "[ok] Kernel image: $KERNEL_IMAGE_PATH"
else
  echo "[warn] Kernel image not found at expected path: $KERNEL_IMAGE_PATH"
fi

if [[ "$DO_SYNC_MODULES" -eq 1 ]]; then
  if [[ ! -x "$TOP_DIR/mkcombinedroot/copy_moduls.sh" ]]; then
    echo "Error: $TOP_DIR/mkcombinedroot/copy_moduls.sh not found or not executable." >&2
    exit 1
  fi

  MODULE_DST="$PRODUCT_OUT/kdiwin_vendor_ramdisk_modules"
  mkdir -p "$MODULE_DST"
  echo "[sync] Copying modules to $MODULE_DST"
  (
    cd "$TOP_DIR/mkcombinedroot"
    KERNEL_MODULES_SRC="$OUT_DIR_ABS" \
    KERNEL_MODULES_DST="$MODULE_DST" \
    ./copy_moduls.sh
  )

  echo "[sync] Module sync done"
fi


echo "Done."
