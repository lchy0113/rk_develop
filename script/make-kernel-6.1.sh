#!/usr/bin/env bash
# Standalone kernel build helper for kernel-6.1.
# Builds out-of-tree, optionally syncs modules and repacks vendor_boot.img.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOP_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
KERNEL_SRC="$SCRIPT_DIR"

OUT_DIR="$TOP_DIR/build_linux-6.1"
TARGETS="Image modules dtbs"
JOBS="$(nproc)"
DO_CLEAN=0
DO_RECONFIG=0
DO_SYNC_MODULES=0
DO_MENUCONFIG=0
DO_REPACK_VENDORBOOT=0

usage() {
  cat <<'EOF'
Usage: ./make-kernel-6.1.sh [options]

Options:
  -o, --out <dir>         External kernel output directory (default: build_linux-6.1)
  -t, --targets "..."     Kernel make targets (default: "Image modules dtbs")
  -j, --jobs <N>          Parallel jobs (default: nproc)
      --clean             Remove output directory before build
      --reconfig          Force defconfig regeneration
      --sync-modules      Sync built modules to PRODUCT_OUT/kdiwin_vendor_ramdisk_modules
      --repack-vendorboot Repack PRODUCT_OUT/vendor_boot.img + resource.img using synced modules/DTB
      menuconfig          Merge configs then open interactive menuconfig (no kernel build)
  -h, --help              Show this help

Examples:
  ./make-kernel-6.1.sh
  ./make-kernel-6.1.sh --reconfig
  ./make-kernel-6.1.sh --sync-modules --repack-vendorboot
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -o|--out)            OUT_DIR="$2";           shift 2 ;;
    -t|--targets)        TARGETS="$2";           shift 2 ;;
    -j|--jobs)           JOBS="$2";              shift 2 ;;
    --clean)             DO_CLEAN=1;             shift ;;
    --reconfig)          DO_RECONFIG=1;          shift ;;
    --sync-modules)      DO_SYNC_MODULES=1;      shift ;;
    --repack-vendorboot) DO_REPACK_VENDORBOOT=1; shift ;;
    menuconfig)          DO_MENUCONFIG=1;        shift ;;
    -h|--help)           usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

cd "$TOP_DIR"

# ── Android build variables ──────────────────────────────────────────────────
TARGET_KERNEL_ARCH="$(get_build_var TARGET_KERNEL_ARCH)"
TARGET_KERNEL_DEFCONFIG="$(get_build_var TARGET_KERNEL_DEFCONFIG)"
TARGET_KERNEL_CONFIGS="$(get_build_var TARGET_KERNEL_CONFIGS)"
TARGET_KERNEL_CROSS_COMPILE_PREFIX="$(get_build_var TARGET_KERNEL_CROSS_COMPILE_PREFIX)"
TARGET_KERNEL_CLANG_PATH="$(get_build_var TARGET_KERNEL_CLANG_PATH)"
TARGET_KERNEL_EXTRA_ARGS="$(get_build_var TARGET_KERNEL_EXTRA_ARGS)"
TARGET_KERNEL_VERSION="$(get_build_var TARGET_KERNEL_VERSION)"
TARGET_KERNEL_DTB="$(get_build_var TARGET_KERNEL_DTB 2>/dev/null || true)"
PRODUCT_OUT="$(get_build_var PRODUCT_OUT)"
BOARD_AVB_ENABLE="$(get_build_var BOARD_AVB_ENABLE 2>/dev/null || echo false)"

if [[ -z "$TARGET_KERNEL_ARCH" || -z "$TARGET_KERNEL_DEFCONFIG" ]]; then
  echo "Error: Required kernel build vars are missing." >&2
  echo "  TARGET_KERNEL_ARCH=$TARGET_KERNEL_ARCH" >&2
  echo "  TARGET_KERNEL_DEFCONFIG=$TARGET_KERNEL_DEFCONFIG" >&2
  exit 1
fi

OUT_DIR_ABS="$(readlink -f "$OUT_DIR")"
PRODUCT_OUT="$(readlink -f "$PRODUCT_OUT")"
HOST_TOOLS_DIR="$TOP_DIR/out/host/linux-x86/bin"

# Add clang to PATH
export PATH="$TOP_DIR/prebuilts/clang/host/linux-x86/clang-r530567/bin:$PATH"

if [[ "$TARGET_KERNEL_ARCH" == "arm64" ]]; then
  ADDON_ARGS="CROSS_COMPILE=aarch64-linux-gnu- LLVM=1 LLVM_IAS=1"
else
  ADDON_ARGS="CC=clang LD=ld.lld"
fi

# ── Clean ────────────────────────────────────────────────────────────────────
if [[ "$DO_CLEAN" -eq 1 ]]; then
  echo "[clean] Removing $OUT_DIR_ABS"
  rm -rf "$OUT_DIR_ABS"
fi

mkdir -p "$OUT_DIR_ABS"

echo "=== Standalone Kernel Build ==="
echo "  Source  : $KERNEL_SRC"
echo "  Out     : $OUT_DIR_ABS"
echo "  Arch    : $TARGET_KERNEL_ARCH"
echo "  Config  : $TARGET_KERNEL_DEFCONFIG"
echo "  Targets : $TARGETS"
echo "  Jobs    : $JOBS"

MAKE_COMMON_ARGS=(
  -C "$KERNEL_SRC"
  O="$OUT_DIR_ABS"
  ARCH="$TARGET_KERNEL_ARCH"
)
if [[ -n "$TARGET_KERNEL_CROSS_COMPILE_PREFIX" ]]; then
  MAKE_COMMON_ARGS+=(CROSS_COMPILE="$TARGET_KERNEL_CROSS_COMPILE_PREFIX")
fi

# ── Kernel config ────────────────────────────────────────────────────────────
if [[ ! -f "$OUT_DIR_ABS/.config" || "$DO_RECONFIG" -eq 1 ]]; then
  KCONFIG_DIR="$TOP_DIR/device/kdiwin/nova/common/kconfig"
  MERGE_KCONFIG_SH="$TOP_DIR/device/kdiwin/nova/common/mergekconfig.sh"

  # Base: defconfig + recommended
  KERNEL_CONFIG_SRC=(
    "$KERNEL_SRC/arch/$TARGET_KERNEL_ARCH/configs/$TARGET_KERNEL_DEFCONFIG"
    "$KCONFIG_DIR/recommended.config"
  )

  # Product fragment configs from TARGET_KERNEL_CONFIGS
  if [[ -n "$TARGET_KERNEL_CONFIGS" ]]; then
    read -r -a _extra_configs <<< "$TARGET_KERNEL_CONFIGS"
    KERNEL_CONFIG_SRC+=("${_extra_configs[@]}")
  fi

  # Product-specific config: device/kdiwin/nova/<product>/<product>.config
  TARGET_DEVICE_DIR="$(get_build_var TARGET_DEVICE_DIR)"
  PRODUCT_NAME="$(get_build_var TARGET_PRODUCT)"
  PRODUCT_CONFIG="$TOP_DIR/$TARGET_DEVICE_DIR/${PRODUCT_NAME}.config"
  [[ -f "$PRODUCT_CONFIG" ]] && KERNEL_CONFIG_SRC+=("$PRODUCT_CONFIG")

  # Development config (opt-in via ENABLE_KERNEL_DEV_CONFIG := true in BoardConfig.mk)
  ENABLE_KERNEL_DEV_CONFIG="$(get_build_var ENABLE_KERNEL_DEV_CONFIG 2>/dev/null || echo false)"
  KERNEL_DEV_CONFIG="$KERNEL_SRC/arch/$TARGET_KERNEL_ARCH/configs/dev.config"
  [[ "$ENABLE_KERNEL_DEV_CONFIG" == "true" && -f "$KERNEL_DEV_CONFIG" ]] && \
    KERNEL_CONFIG_SRC+=("$KERNEL_DEV_CONFIG")

  # Required configs (arch/version-specific): appended last so they override everything
  KERNEL_CONFIG_REQUIRED_SRC=("$KCONFIG_DIR/common.config")
  [[ -f "$KCONFIG_DIR/$TARGET_KERNEL_ARCH.config" ]] && \
    KERNEL_CONFIG_REQUIRED_SRC+=("$KCONFIG_DIR/$TARGET_KERNEL_ARCH.config")
  [[ -n "$TARGET_KERNEL_VERSION" && -f "$KCONFIG_DIR/$TARGET_KERNEL_VERSION/common.config" ]] && \
    KERNEL_CONFIG_REQUIRED_SRC+=("$KCONFIG_DIR/$TARGET_KERNEL_VERSION/common.config")
  [[ -n "$TARGET_KERNEL_VERSION" && -f "$KCONFIG_DIR/$TARGET_KERNEL_VERSION/$TARGET_KERNEL_ARCH.config" ]] && \
    KERNEL_CONFIG_REQUIRED_SRC+=("$KCONFIG_DIR/$TARGET_KERNEL_VERSION/$TARGET_KERNEL_ARCH.config")

  KERNEL_CONFIG_REQUIRED="$OUT_DIR_ABS/.config.required"
  printf '%s\n' "${KERNEL_CONFIG_REQUIRED_SRC[@]}" > "$KERNEL_CONFIG_REQUIRED"
  KERNEL_CONFIG_SRC+=("$KERNEL_CONFIG_REQUIRED")

  echo "[config] Merging kernel configs:"
  printf '  - %s\n' "${KERNEL_CONFIG_SRC[@]}"

  LLVM=1 LLVM_IAS=1 "$MERGE_KCONFIG_SH" \
    "$KERNEL_SRC" "$OUT_DIR_ABS" "$TARGET_KERNEL_ARCH" \
    "$TARGET_KERNEL_CROSS_COMPILE_PREFIX" "${KERNEL_CONFIG_SRC[@]}"
fi

# ── Menuconfig ───────────────────────────────────────────────────────────────
if [[ "$DO_MENUCONFIG" -eq 1 ]]; then
  # shellcheck disable=SC2086
  make "${MAKE_COMMON_ARGS[@]}" $TARGET_KERNEL_EXTRA_ARGS $ADDON_ARGS menuconfig
  echo "[menuconfig] Done. Config saved to $OUT_DIR_ABS/.config"
  exit 0
fi

# ── Build ────────────────────────────────────────────────────────────────────
echo "[build] Building: $TARGETS"
# shellcheck disable=SC2086
make -j"$JOBS" "${MAKE_COMMON_ARGS[@]}" $TARGET_KERNEL_EXTRA_ARGS $ADDON_ARGS $TARGETS

KERNEL_IMAGE_PATH="$OUT_DIR_ABS/arch/$TARGET_KERNEL_ARCH/boot/Image"
if [[ -f "$KERNEL_IMAGE_PATH" ]]; then
  echo "[build] Kernel image: $KERNEL_IMAGE_PATH"
else
  echo "[build] Warning: Kernel image not found: $KERNEL_IMAGE_PATH"
fi

# ── Sync modules ─────────────────────────────────────────────────────────────
if [[ "$DO_SYNC_MODULES" -eq 1 ]]; then
  if [[ ! -x "$TOP_DIR/mkcombinedroot/copy_moduls.sh" ]]; then
    echo "Error: copy_moduls.sh not found or not executable." >&2
    exit 1
  fi

  MODULE_DST="$PRODUCT_OUT/kdiwin_vendor_ramdisk_modules"
  mkdir -p "$MODULE_DST"

  echo "[sync] Copying modules → $MODULE_DST"
  (
    cd "$TOP_DIR/mkcombinedroot"
    KERNEL_MODULES_SRC="$OUT_DIR_ABS" \
    KERNEL_MODULES_DST="$MODULE_DST" \
    ./copy_moduls.sh
  )

  # Strip debug symbols to reduce ramdisk size (~80% reduction per .ko)
  LLVM_STRIP="$TOP_DIR/prebuilts/clang/host/linux-x86/clang-r530567/bin/llvm-strip"
  if [[ -x "$LLVM_STRIP" ]]; then
    echo "[sync] Stripping debug symbols..."
    find "$MODULE_DST" -name "*.ko" | while read -r ko; do
      "$LLVM_STRIP" --strip-debug "$ko" -o "${ko}.stripped" && mv "${ko}.stripped" "$ko"
    done
    echo "[sync] Modules size after strip: $(du -sh "$MODULE_DST" | cut -f1)"
  else
    echo "[sync] Warning: llvm-strip not found, skipping strip"
  fi

  # kheaders.ko is only needed for in-kernel header builds, not at runtime
  rm -f "$MODULE_DST/kheaders.ko"

  # Copy depmod metadata (modules.dep, modules.alias, modules.load, etc.)
  # Android build generates these under depmod_VENDOR_RAMDISK_intermediates.
  # strip --strip-debug does not change ELF symbols so modules.dep remains valid.
  ANDROID_DEPMOD_SRC="$PRODUCT_OUT/obj/PACKAGING/depmod_VENDOR_RAMDISK_intermediates/lib/modules/0.0"
  if [[ -d "$ANDROID_DEPMOD_SRC" ]]; then
    echo "[sync] Copying depmod metadata from Android build..."
    for meta in modules.dep modules.alias modules.softdep modules.devname modules.symbols modules.load; do
      [[ -f "$ANDROID_DEPMOD_SRC/$meta" ]] && cp -f "$ANDROID_DEPMOD_SRC/$meta" "$MODULE_DST/"
    done
  else
    # Fallback: run depmod directly (path format matches Android: leading /)
    echo "[sync] Warning: Android depmod intermediates not found, running depmod as fallback..."
    DEPMOD_TOOL="$HOST_TOOLS_DIR/depmod"
    [[ ! -x "$DEPMOD_TOOL" ]] && DEPMOD_TOOL="$(which depmod 2>/dev/null || true)"
    if [[ -x "$DEPMOD_TOOL" ]]; then
      DEPMOD_STAGING=$(mktemp -d)
      mkdir -p "$DEPMOD_STAGING/lib/modules"
      find "$MODULE_DST" -name "*.ko" -exec cp -f {} "$DEPMOD_STAGING/lib/modules/" \;
      "$DEPMOD_TOOL" -b "$DEPMOD_STAGING" 0.0 2>/dev/null || true
      if [[ -d "$DEPMOD_STAGING/lib/modules/0.0" ]]; then
        sed -i -e 's|\([^: ]*lib/modules/[^: ]*\)|/\1|g' \
          "$DEPMOD_STAGING/lib/modules/0.0/modules.dep" 2>/dev/null || true
        for meta in modules.dep modules.alias modules.softdep modules.devname modules.symbols; do
          [[ -f "$DEPMOD_STAGING/lib/modules/0.0/$meta" ]] && \
            cp -f "$DEPMOD_STAGING/lib/modules/0.0/$meta" "$MODULE_DST/"
        done
      fi
      rm -rf "$DEPMOD_STAGING"
    else
      echo "[sync] Error: depmod not found — modules will not load at boot!" >&2
    fi
  fi

  echo "[sync] Done: $(ls -1 "$MODULE_DST"/*.ko 2>/dev/null | wc -l) modules, metadata: $(ls "$MODULE_DST"/modules.* 2>/dev/null | xargs -r -n1 basename | tr '\n' ' ')"
fi

# ── Repack vendor_boot.img ───────────────────────────────────────────────────
if [[ "$DO_REPACK_VENDORBOOT" -eq 1 ]]; then
  VENDOR_BOOT_IMG="$PRODUCT_OUT/vendor_boot.img"
  MODULE_DST="$PRODUCT_OUT/kdiwin_vendor_ramdisk_modules"

  # Resolve host tools (fall back to u-boot scripts if Android prebuilts not built yet)
  UNPACK_BOOTIMG="$HOST_TOOLS_DIR/unpack_bootimg"
  MKBOOTIMG_TOOL="$HOST_TOOLS_DIR/mkbootimg"
  LZ4_TOOL="$HOST_TOOLS_DIR/lz4"
  MKBOOTFS_TOOL="$HOST_TOOLS_DIR/mkbootfs"
  [[ ! -x "$UNPACK_BOOTIMG" ]] && UNPACK_BOOTIMG="$TOP_DIR/u-boot/scripts/unpack_bootimg"
  [[ ! -x "$MKBOOTIMG_TOOL" ]] && MKBOOTIMG_TOOL="$TOP_DIR/u-boot/scripts/mkbootimg"
  [[ ! -x "$LZ4_TOOL" ]]       && LZ4_TOOL="lz4"
  [[ ! -x "$MKBOOTFS_TOOL" ]]  && MKBOOTFS_TOOL=""

  [[ ! -f "$VENDOR_BOOT_IMG" ]] && { echo "[repack] Error: vendor_boot.img not found: $VENDOR_BOOT_IMG" >&2; exit 1; }
  [[ ! -d "$MODULE_DST" ]]      && { echo "[repack] Error: module dir not found — run --sync-modules first" >&2; exit 1; }
  [[ ! -x "$UNPACK_BOOTIMG" ]]  && { echo "[repack] Error: unpack_bootimg not found" >&2; exit 1; }
  [[ ! -x "$MKBOOTIMG_TOOL" ]]  && { echo "[repack] Error: mkbootimg not found" >&2; exit 1; }

  # Force-rebuild DTB so the repacked image always contains the latest source
  if [[ -n "$TARGET_KERNEL_DTB" ]]; then
    DTB_BUILD_PATH="$OUT_DIR_ABS/arch/$TARGET_KERNEL_ARCH/boot/dts/$TARGET_KERNEL_DTB"
    rm -f "$DTB_BUILD_PATH"
    # shellcheck disable=SC2086
    make -j"$JOBS" "${MAKE_COMMON_ARGS[@]}" $TARGET_KERNEL_EXTRA_ARGS dtbs > /dev/null 2>&1
    echo "[repack] DTB rebuilt: $DTB_BUILD_PATH"
  fi

  # ── Repack resource.img ──────────────────────────────────────────────────
  # Rockchip U-Boot reads the DTB from resource partition (not vendor_boot).
  # resource.img format (RSCE): rk-kernel.dtb + logo.bmp + logo_kernel.bmp
  # resource_tool is a host tool compiled alongside the kernel build.
  RESOURCE_IMG="$PRODUCT_OUT/resource.img"
  RESOURCE_TOOL="$OUT_DIR_ABS/scripts/resource_tool"
  DTB_FOR_RESOURCE="$OUT_DIR_ABS/arch/$TARGET_KERNEL_ARCH/boot/dts/$TARGET_KERNEL_DTB"

  if [[ -x "$RESOURCE_TOOL" && -f "$DTB_FOR_RESOURCE" ]]; then
    # Prefer .dev variants when present (e.g. logo.bmp.dev overrides logo.bmp).
    # resource_tool stores the filename as-is, so copy .dev files to a tmp dir
    # with canonical names (logo.bmp / logo_kernel.bmp) before packing.
    LOGO_TMP_DIR=$(mktemp -d)
    LOGO_ARGS=()
    for logo in logo.bmp logo_kernel.bmp; do
      if [[ -f "$KERNEL_SRC/${logo}.dev" ]]; then
        cp "$KERNEL_SRC/${logo}.dev" "$LOGO_TMP_DIR/$logo"
        LOGO_ARGS+=("$LOGO_TMP_DIR/$logo")
      elif [[ -f "$KERNEL_SRC/$logo" ]]; then
        LOGO_ARGS+=("$KERNEL_SRC/$logo")
      fi
    done

    RESOURCE_TMP="$PRODUCT_OUT/resource.img.new"
    (cd "$OUT_DIR_ABS" && "$RESOURCE_TOOL" "$DTB_FOR_RESOURCE" "${LOGO_ARGS[@]}" > /dev/null)
    rm -rf "$LOGO_TMP_DIR"
    mv "$OUT_DIR_ABS/resource.img" "$RESOURCE_TMP"
    mv "$RESOURCE_TMP" "$RESOURCE_IMG"
    echo "[repack] resource.img updated: $RESOURCE_IMG ($(du -sh "$RESOURCE_IMG" | cut -f1))"
  else
    echo "[repack] Warning: resource_tool or DTB not found, skipping resource.img update"
    [[ ! -x "$RESOURCE_TOOL" ]] && echo "[repack]   resource_tool: $RESOURCE_TOOL"
    [[ ! -f "$DTB_FOR_RESOURCE" ]] && echo "[repack]   DTB: $DTB_FOR_RESOURCE"
  fi

  TMP_VENDOR_BOOT="$(mktemp -d "$PRODUCT_OUT/vendor_boot_repack.XXXXXX")"
  RAMDISK_EXTRACT_DIR="$TMP_VENDOR_BOOT/ramdisk"
  VENDOR_RAMDISK="$TMP_VENDOR_BOOT/vendor_ramdisk00"
  VENDOR_BOOT_IMG_NEW="$PRODUCT_OUT/vendor_boot.img.new"

  trap 'rm -rf "$TMP_VENDOR_BOOT"' EXIT

  # ── Unpack ──────────────────────────────────────────────────────────────
  echo "[repack] Unpacking vendor_boot.img..."
  "$UNPACK_BOOTIMG" --boot_img "$VENDOR_BOOT_IMG" --out "$TMP_VENDOR_BOOT" > /dev/null
  [[ ! -f "$VENDOR_RAMDISK" ]] && { echo "[repack] Error: vendor_ramdisk00 not found" >&2; exit 1; }

  # ── Decompress ramdisk ──────────────────────────────────────────────────
  mkdir -p "$RAMDISK_EXTRACT_DIR"
  if file "$VENDOR_RAMDISK" | grep -q "gzip"; then
    RAMDISK_COMPRESS_FORMAT="gzip"
    gzip -dc "$VENDOR_RAMDISK" | (cd "$RAMDISK_EXTRACT_DIR" && cpio -idm 2>/dev/null) || true
  elif file "$VENDOR_RAMDISK" | grep -q "LZ4"; then
    RAMDISK_COMPRESS_FORMAT="lz4"
    "$LZ4_TOOL" -dc "$VENDOR_RAMDISK" | (cd "$RAMDISK_EXTRACT_DIR" && cpio -idm 2>/dev/null) || true
  else
    RAMDISK_COMPRESS_FORMAT="none"
    (cd "$RAMDISK_EXTRACT_DIR" && cpio -idm < "$VENDOR_RAMDISK" 2>/dev/null) || true
  fi
  echo "[repack] Ramdisk format: $RAMDISK_COMPRESS_FORMAT"

  # ── Replace modules ─────────────────────────────────────────────────────
  MODULES_DIR="$RAMDISK_EXTRACT_DIR/lib/modules"
  rm -rf "$MODULES_DIR"
  mkdir -p "$MODULES_DIR"
  cp -a "$MODULE_DST"/. "$MODULES_DIR/"
  echo "[repack] Modules: $(ls -1 "$MODULES_DIR"/*.ko 2>/dev/null | wc -l) .ko files"

  # ── Recompress ramdisk ──────────────────────────────────────────────────
  # Use mkbootfs (Android prebuilt) when available — identical to 'make vendorbootimage'.
  # Compression mirrors build/core/Makefile COMPRESSION_COMMAND for lz4:
  #   -l               : legacy LZ4 format required by kernel early-boot decompressor
  #   -12 --favor-decSpeed : max compression, optimised for fast decompression
  if [[ -n "$MKBOOTFS_TOOL" ]]; then
    GEN_CPIO=("$MKBOOTFS_TOOL" "$RAMDISK_EXTRACT_DIR")
  else
    GEN_CPIO=(bash -c "cd '$RAMDISK_EXTRACT_DIR' && find . | cpio -o -H newc")
  fi

  case "$RAMDISK_COMPRESS_FORMAT" in
    gzip) "${GEN_CPIO[@]}" | gzip > "$VENDOR_RAMDISK" ;;
    lz4)  "${GEN_CPIO[@]}" | "$LZ4_TOOL" -l -12 --favor-decSpeed > "$VENDOR_RAMDISK" ;;
    *)    "${GEN_CPIO[@]}" > "$VENDOR_RAMDISK" ;;
  esac
  echo "[repack] Ramdisk size: $(du -sh "$VENDOR_RAMDISK" | cut -f1)"

  # Save repacked ramdisk — the second unpack_bootimg call (for mkbootimg args)
  # overwrites vendor_ramdisk00, so preserve it first.
  REPACKED_RAMDISK="$TMP_VENDOR_BOOT/vendor_ramdisk00.repacked"
  cp "$VENDOR_RAMDISK" "$REPACKED_RAMDISK"

  # ── Build mkbootimg args from original image ─────────────────────────────
  # unpack_bootimg --format=mkbootimg emits --vendor_ramdisk_fragment (v4 header)
  # and --ramdisk_type/--ramdisk_name which mkbootimg does not accept for repacking.
  MKBOOTIMG_ARGS=()
  while IFS= read -r -d '' arg; do
    MKBOOTIMG_ARGS+=("$arg")
  done < <("$UNPACK_BOOTIMG" --boot_img "$VENDOR_BOOT_IMG" --out "$TMP_VENDOR_BOOT" --format=mkbootimg -0)

  # Fix: --vendor_ramdisk_fragment → --vendor_ramdisk
  for i in "${!MKBOOTIMG_ARGS[@]}"; do
    [[ "${MKBOOTIMG_ARGS[$i]}" == "--vendor_ramdisk_fragment" ]] && MKBOOTIMG_ARGS[$i]="--vendor_ramdisk"
  done

  # Fix: remove --ramdisk_type and --ramdisk_name (each followed by one value)
  FILTERED_ARGS=()
  i=0
  while [[ $i -lt ${#MKBOOTIMG_ARGS[@]} ]]; do
    if [[ "${MKBOOTIMG_ARGS[$i]}" == "--ramdisk_type" || "${MKBOOTIMG_ARGS[$i]}" == "--ramdisk_name" ]]; then
      ((i += 2))
    else
      FILTERED_ARGS+=("${MKBOOTIMG_ARGS[$i]}")
      ((i += 1))
    fi
  done
  MKBOOTIMG_ARGS=("${FILTERED_ARGS[@]}")

  # Restore our repacked ramdisk (second unpack_bootimg above overwrote it)
  cp "$REPACKED_RAMDISK" "$VENDOR_RAMDISK"

  # ── Replace DTB ──────────────────────────────────────────────────────────
  if [[ -n "${TARGET_KERNEL_DTB:-}" ]]; then
    DTB_STANDALONE="$OUT_DIR_ABS/arch/$TARGET_KERNEL_ARCH/boot/dts/$TARGET_KERNEL_DTB"
    DTB_ANDROID="$PRODUCT_OUT/obj/KERNEL_OBJ/arch/$TARGET_KERNEL_ARCH/boot/dts/$TARGET_KERNEL_DTB"

    NEW_DTB=""
    if [[ -f "$DTB_STANDALONE" && -f "$DTB_ANDROID" ]]; then
      [[ "$DTB_STANDALONE" -nt "$DTB_ANDROID" ]] && NEW_DTB="$DTB_STANDALONE" || NEW_DTB="$DTB_ANDROID"
    elif [[ -f "$DTB_STANDALONE" ]]; then
      NEW_DTB="$DTB_STANDALONE"
    elif [[ -f "$DTB_ANDROID" ]]; then
      NEW_DTB="$DTB_ANDROID"
    fi

    if [[ -n "$NEW_DTB" ]]; then
      cp "$NEW_DTB" "$TMP_VENDOR_BOOT/dtb"
      echo "[repack] DTB: $NEW_DTB"
    else
      echo "[repack] Warning: no built DTB found, keeping original"
    fi
  fi

  # ── Pack vendor_boot.img ─────────────────────────────────────────────────
  echo "[repack] Building vendor_boot.img..."
  "$MKBOOTIMG_TOOL" "${MKBOOTIMG_ARGS[@]}" --vendor_boot "$VENDOR_BOOT_IMG_NEW"

  if [[ "$BOARD_AVB_ENABLE" == "true" ]]; then
    echo "[repack] Warning: AVB enabled — image may need re-signing (add_hash_footer)"
  fi

  mv "$VENDOR_BOOT_IMG_NEW" "$VENDOR_BOOT_IMG"
  echo "[repack] Done: $VENDOR_BOOT_IMG ($(du -sh "$VENDOR_BOOT_IMG" | cut -f1))"
fi

echo "Done."
