# This file xman_list_rb is part of xman utility.
#
# Copyright (c) 2006-2007 Chung Shin Yee <cshinyee@gmail.com>
#
#       http://myxman.org
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
# USA.
#
# The GNU General Public License is contained in the file COPYING.
#

#!/usr/bin/env bash

# Date  : 22 Feb 2006

# Syntax: xman_list_rb

# Description: List the deleted files in recycle bin.

# Given: 
# Output: A list of deleted files in recycle bin.

# Known problems/limitations:

RECYCLE_BIN="$HOME/.recycle_bin"
DIR_DELETED=".deleted"
DFILE_LIST="deleted_file.txt"

TIMEFORMAT="+%Y.%m%d.%H%S.%N"

COMMAND_DEL="DEL"

#########################################################################################

if [ ! -e "$RECYCLE_BIN/$DFILE_LIST" ] ; then
	echo "Nothing to list."
	exit 0 
fi 

echo "Listing deleted files in recycle bin."

let count=0
exec < "$RECYCLE_BIN/$DFILE_LIST"
while read instr
do
	
	# echo "$instr $orig_fname $del_fname" 
	if [ "$instr" == "$COMMAND_DEL" ] ; then
		read -r orig_fname
		read -r del_fname
		# echo "INSTR: $instr"
		# echo "ORIG: $orig_fname"
		# echo "DEL: $del_fname"
		if [ -e "$del_fname" ] ; then
			let count=count+1
			echo "$count: $del_fname"
		else
			echo "$del_fname no longer exists"
		fi
	fi
done
exec <&-

echo "Listing completed."

exit 0

#eof

