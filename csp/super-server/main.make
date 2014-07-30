# -*- Makefile -*-
# $Id$

# Copyright (C) 2014 Alexander Chernov <cher@ejudge.ru> */

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.

ifdef RELEASE
CDEBUGFLAGS=-O2 -Wall -DNDEBUG -DRELEASE ${WERROR}
else
CDEBUGFLAGS=-g -Wall ${WERROR}
endif
CEXTRAFLAGS=
LDEXTRAFLAGS=
EXTRALIBS=
CCOMPFLAGS=-D_GNU_SOURCE -std=gnu99 -I../.. -I../../include -g -DPIC -fPIC
LDCOMPFLAGS= -g -shared
EXESFX=

LDLIBS=${EXTRALIBS} -lz $(LIBINTL) $(LIBICONV) $(LIBLIBICONV) -lm
CFLAGS=${CDEBUGFLAGS} ${CCOMPFLAGS} ${CEXTRAFLAGS} ${WPTRSIGN}
LDFLAGS=${CDEBUGFLAGS} ${LDCOMPFLAGS} ${LDEXTRAFLAGS}
CC=gcc
LD=gcc
EXPAT_LIB=-lexpat

TARGETDIR = ${libexecdir}/ejudge/csp/contests
CFILES = \
 csp_check_tests_page.c\
 csp_cnts_edit_permissions_page.c\
 csp_contest_already_edited_page.c\
 csp_contest_page.c\
 csp_contest_xml_page.c\
 csp_create_contest_page.c\
 csp_login_page.c\
 csp_main_page.c\
 csp_problem_packages_page.c

SOFILES = $(CFILES:.c=.so)

all : $(CFILES) $(SOFILES)

install : all
	install -d "${DESTDIR}${prefix}/share/ejudge/csp/super-server"
	for i in *.csp; do install -m 0644 $$i "${DESTDIR}${prefix}/share/ejudge/csp/super-server"; done
	for i in I_*.c; do install -m 0644 $$i "${DESTDIR}${prefix}/share/ejudge/csp/super-server"; done

clean : 
	-rm -f *.o *.so *.ds csp_*.c

po : super-server.po
super-server.po : $(CFILES)
	${XGETTEXT} -d ejudge --no-location --foreign-user  -k_ -k__ -s -o $@ *.c

csp_main_page.so : csp_main_page.c I_main_page.c
	$(CC) $(CCOMPFLAGS) ${WPTRSIGN} $(LDFLAGS) $^ -o $@
csp_check_tests_page.so : csp_check_tests_page.c I_check_tests_page.c
	$(CC) $(CCOMPFLAGS) ${WPTRSIGN} $(LDFLAGS) $^ -o $@

csp_check_tests_page.c : check_tests_page.csp includes.csp stdvars.csp header.csp footer.csp
csp_cnts_edit_permissions_page.c : cnts_edit_permissions_page.csp includes.csp stdvars.csp header.csp footer.csp
csp_contest_already_edited_page.c : contest_already_edited_page.csp includes.csp stdvars.csp header.csp footer.csp
csp_contest_page.c : contest_page.csp includes.csp stdvars.csp header.csp footer.csp
csp_contest_xml_page.c : contest_xml_page.csp includes.csp stdvars.csp header.csp footer.csp
csp_create_contest_page.c : create_contest_page.csp includes.csp stdvars.csp header.csp footer.csp
csp_login_page.c : main_page.csp includes.csp stdvars.csp header.csp footer.csp
csp_main_page.c : main_page.csp includes.csp stdvars.csp header.csp footer.csp
csp_problem_packages_page.c : problem_packages_page.csp includes.csp stdvars.csp header.csp footer.csp

csp_%.c : %.csp
	../../ej-page-gen -o $@ -d $*.ds $<

%.o : %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.so : %.o
	$(CC) $(LDFLAGS) $< -o $@
