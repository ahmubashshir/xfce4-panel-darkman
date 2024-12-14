ACLOCAL_AMFLAGS = -I m4
AM_VALAFLAGS = --pkg=gtk+-3.0 --pkg=libxfce4panel-2.0 --vapidir=$(builddir)/src --pkg=config

plugindir = $(libdir)/xfce4/panel/plugins
plugin_LTLIBRARIES = libdarkman.la

libdarkman_la_SOURCES = src/darkman.vala src/plugin.vala
libdarkman_la_CFLAGS = @LIBXFCE4PANEL_CFLAGS@ -Wno-discarded-qualifiers
libdarkman_la_LIBADD = @LIBXFCE4PANEL_LIBS@

desktopdir = $(datadir)/xfce4/panel/plugins
desktop_DATA = data/darkman.desktop
