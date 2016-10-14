#!/bin/sh
rm -f hiawatha.wbm.gz
cp --preserve LICENCE hiawatha/
tar cvzf hiawatha.wbm.gz hiawatha/
rm hiawatha/LICENCE
