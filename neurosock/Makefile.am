# neurosock/Makefile.am: part of meabench, an MEA recording and analysis tool
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


bin_PROGRAMS = mea_neurosock
noinst_HEADERS = Error.H MedianFlt.H Neurosock.H Defs.H srvCMOS.H srvMeata.H FrameBuffer.H Mutex.H
EXTRA_mea_neurosock_SOURCES = mea_neurosock.C Neurosock.C srvCMOS.C
mea_neurosock_SOURCES = mea_neurosock.C Neurosock.C FrameBuffer.C srvCMOS.C

INCLUDES=-I$(top_srcdir)
