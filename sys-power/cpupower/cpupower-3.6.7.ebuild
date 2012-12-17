# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils multilib

MY_P="linux-${PV/_/-}"

DESCRIPTION="successor to cpufrequtils distributed along Linux kernel sources"
HOMEPAGE="http://lwn.net/Articles/433002/"
case "${PV}" in
	*_rc[0-9]*)
		SRC_URI="mirror://kernel/linux/kernel/v3.x/testing/${MY_P}.tar.bz2"
		;;
	*)
		SRC_URI="mirror://kernel/linux/kernel/v3.x/${MY_P}.tar.bz2"
		;;
esac

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="nls benchmark"

# while the binaries are renamed, other files still collide
RDEPEND="!sys-power/cpufrequtils"

S="${WORKDIR}/${MY_P}/tools/power/cpupower"

src_unpack() {
	local extract_only extract_list
	extract_only="Makefile tools/power/cpupower/"
	for file in ${extract_only}; do
		extract_list+=" ${MY_P}/${file}"
	done
	tar -xjpf "${DISTDIR}/${A}" ${extract_list}
}

src_compile() {
	# set strip command to no-op so that is is handled by portage
	emake \
		V=1 \
		STRIP=/bin/true \
		DEBUG=false \
		NLS=$(usex nls true false) \
		CPUFREQ_BENCH=$(usex benchmark true false)
}

src_install() {
	# cannot use einstall as it encodes ${ED} into {bin,man,doc,...}dir
	# the flags need to be repeated, otherwise this bench files are installed
	emake \
		NLS=$(usex nls true false) \
		CPUFREQ_BENCH=$(usex benchmark true false) \
		DESTDIR="${D}" \
		mandir="/usr/share/man" \
		docdir="/usr/share/doc/${PF}" \
		libdir="/usr/$(get_libdir)" \
		install
}