# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX

PKG_NAME="SDL3"
PKG_VERSION="3.4.2"
PKG_SHA256="ef39a2e3f9a8a78296c40da701967dd1b0d0d6e267e483863ce70f8a03b4050c"
PKG_LICENSE="zlib"
PKG_SITE="https://www.libsdl.org/"
PKG_URL="https://www.libsdl.org/release/SDL3-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain alsa-lib systemd dbus pulseaudio libdrm"
PKG_LONGDESC="Simple DirectMedia Layer 3 - cross-platform low-level access to audio, keyboard, mouse, joystick, and graphics hardware."
PKG_TOOLCHAIN="cmake"

if [ ! "${OPENGL_SUPPORT}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu"
  PKG_CMAKE_OPTS_TARGET+=" -DSDL_OPENGL=ON \
                           -DSDL_KMSDRM=OFF \
                           -DSDL_KMSDRM_SHARED=OFF"
else
  PKG_CMAKE_OPTS_TARGET+=" -DSDL_OPENGL=OFF \
                           -DSDL_KMSDRM=OFF \
                           -DSDL_KMSDRM_SHARED=OFF"
fi

if [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  PKG_CMAKE_OPTS_TARGET+=" -DSDL_OPENGLES=ON \
                           -DSDL_KMSDRM=ON \
                           -DSDL_KMSDRM_SHARED=ON"
else
  PKG_CMAKE_OPTS_TARGET+=" -DSDL_OPENGLES=OFF"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${VULKAN}"
  PKG_CMAKE_OPTS_TARGET+=" -DSDL_VULKAN=ON \
                           -DSDL_RENDER_VULKAN=ON"
else
  PKG_CMAKE_OPTS_TARGET+=" -DSDL_VULKAN=OFF \
                           -DSDL_RENDER_VULKAN=OFF"
fi

if [ "${DISPLAYSERVER}" = "wl" ]; then
  PKG_DEPENDS_TARGET+=" wayland"
  case ${ARCH} in
    arm)
      true
      ;;
    *)
      PKG_DEPENDS_TARGET+=" ${WINDOWMANAGER}"
      ;;
  esac
  PKG_CMAKE_OPTS_TARGET+=" -DSDL_WAYLAND=ON \
                           -DSDL_WAYLAND_SHARED=ON \
                           -DSDL_WAYLAND_LIBDECOR=OFF \
                           -DSDL_WAYLAND_LIBDECOR_SHARED=OFF"
else
  PKG_CMAKE_OPTS_TARGET+=" -DSDL_WAYLAND=OFF \
                           -DSDL_WAYLAND_SHARED=OFF \
                           -DSDL_WAYLAND_LIBDECOR=OFF \
                           -DSDL_WAYLAND_LIBDECOR_SHARED=OFF"
fi

case ${DEVICE} in
  RK*)
    PKG_DEPENDS_TARGET+=" librga"
    PKG_PATCH_DIRS_TARGET+="${DEVICE}"
    PKG_CMAKE_OPTS_TARGET+=" -DSDL_ROCKCHIP=ON"
  ;;
esac

pre_configure_target() {
  if [ -n "${PKG_PATCH_DIRS_TARGET}" ]; then
    if [ -d "${PKG_DIR}/patches/${PKG_PATCH_DIRS_TARGET}" ]; then
      cd $(get_build_dir SDL3)
      for PATCH in ${PKG_DIR}/patches/${PKG_PATCH_DIRS_TARGET}/*; do
        patch -p1 <${PATCH}
      done
      cd -
    fi
  fi

  export LDFLAGS="${LDFLAGS} -ludev"

  PKG_CMAKE_OPTS_TARGET+=" \
    -DSDL_SHARED=ON \
    -DSDL_STATIC=OFF \
    -DSDL_TESTS=OFF \
    -DSDL_INSTALL_TESTS=OFF \
    -DSDL_EXAMPLES=OFF \
    -DSDL_LIBC=ON \
    -DSDL_GCC_ATOMICS=ON \
    -DSDL_LIBUDEV=ON \
    -DSDL_DBUS=OFF \
    -DSDL_PTHREADS=ON \
    -DSDL_PTHREADS_SEM=ON \
    -DSDL_DLOPEN=ON \
    -DSDL_RPATH=OFF \
    -DSDL_CLOCK_GETTIME=OFF \
    -DSDL_OSS=OFF \
    -DSDL_ALSA=ON \
    -DSDL_ALSA_SHARED=ON \
    -DSDL_JACK=OFF \
    -DSDL_JACK_SHARED=OFF \
    -DSDL_PULSEAUDIO=ON \
    -DSDL_PULSEAUDIO_SHARED=ON \
    -DSDL_PIPEWIRE=ON \
    -DSDL_PIPEWIRE_SHARED=ON \
    -DSDL_SNDIO=OFF \
    -DSDL_SNDIO_SHARED=OFF \
    -DSDL_DISKAUDIO=OFF \
    -DSDL_DUMMYAUDIO=OFF \
    -DSDL_DUMMYVIDEO=OFF \
    -DSDL_DUMMYCAMERA=OFF \
    -DSDL_OFFSCREEN=OFF \
    -DSDL_COCOA=OFF \
    -DSDL_METAL=OFF \
    -DSDL_RENDER_METAL=OFF \
    -DSDL_RENDER_GPU=ON \
    -DSDL_RENDER_D3D=OFF \
    -DSDL_RENDER_D3D11=OFF \
    -DSDL_RENDER_D3D12=OFF \
    -DSDL_DIRECTX=OFF \
    -DSDL_VIVANTE=OFF \
    -DSDL_OPENVR=OFF \
    -DSDL_TSLIB=ON \
    -DSDL_HIDAPI=ON \
    -DSDL_HIDAPI_JOYSTICK=ON \
    -DSDL_HIDAPI_LIBUSB=OFF \
    -DSDL_HIDAPI_LIBUSB_SHARED=OFF \
    -DSDL_VIRTUAL_JOYSTICK=ON \
    -DSDL_FRIBIDI=OFF \
    -DSDL_FRIBIDI_SHARED=OFF \
    -DSDL_LIBTHAI=OFF \
    -DSDL_LIBTHAI_SHARED=OFF \
    -DSDL_LIBSAMPLERATE=OFF \
    -DSDL_ALTIVEC=OFF \
    -DSDL_X11=OFF \
    -DSDL_X11_SHARED=OFF \
    -DSDL_X11_XCURSOR=OFF \
    -DSDL_X11_XDBE=OFF \
    -DSDL_X11_XFIXES=OFF \
    -DSDL_X11_XINPUT=OFF \
    -DSDL_X11_XRANDR=OFF \
    -DSDL_X11_XSCRNSAVER=OFF \
    -DSDL_X11_XSHAPE=OFF \
    -DSDL_X11_XSYNC=OFF \
    -DSDL_X11_XTEST=OFF \
    -DSDL_XINPUT=OFF \
    -DSDL_IBUS=OFF \
    -DSDL_RPI=OFF \
    -DSDL_WASAPI=OFF \
    "
}

post_makeinstall_target() {
  # SDL3 uses CMake find_package only, no shell config script to patch
  rm -rf ${INSTALL}/usr/bin
}
