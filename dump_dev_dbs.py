#!/usr/bin/python

# Script to dump development site DBs and commit them to svn (should be run as 'aegir' user)

import os
from stat import *

private_dir = '/var/aegir/trunk-private/sites'
sites = {'tobaccofree':'tobaccofree'}

for site in sites:
  db = sites[site]
  dir = os.path.join(private_dir, site)
  dumpfile = 'dev.' + site + '.dump.mysql'
  print dir  
  print db
  print dumpfile
  cmd = 'mysqldump --extended-insert=false '+ db + ' >' + dumpfile
  svn = 'svn commit -m "automated dump of '+site+' dev db"'
  print cmd
  print svn
  os.chdir(dir)
  os.system(cmd)
  os.system(svn)
