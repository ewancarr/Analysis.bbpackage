#!/bin/sh
pbpaste | perl -ne 'BEGIN{$s="[";} chomp; s/"/\\"/g; $s.=qq("$_", ); END{$s=~s/, $/]/; print $s}'
