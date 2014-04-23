# mea_rawsrv/Makefile.am: part of meabench, an MEA recording and analysis tool
# Copyright (C) 2000-2002  Daniel Wagenaar (wagenaar@caltech.edu)
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


bin_PROGRAMS = mea_nssrv
#bin_PROGRAMS = mea_rawsrv mea_nssrv
noinst_HEADERS = Aux.H Defs.H RawSource.H RS_MCS.H RS_Sock.H UEIConfig.H rawsrv.C
#mea_rawsrv_SOURCES = RS_MCS.C mcssrv.C
mea_nssrv_SOURCES = nssrv.C RS_Sock.C 


include $(top_srcdir)/Makefile.base
