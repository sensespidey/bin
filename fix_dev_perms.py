#!/usr/bin/python

import os
from stat import *

platform_dir = '/home/web/platform/sites'
sites = ('tobaccofree','ltc','groups')

def chmod_walk(dirname):
  for root,dirs,files in os.walk(dirname):
    for name in files:
      my_file = os.path.join(root,name)
      mode = os.stat(my_file)
      try:
	os.chmod(my_file,0664)
	print "CHMOD G+W",my_file
      except:
	print "Couldn't chmod",my_file

for site in sites:
  site_dir = os.path.join(platform_dir,site)
  themes = os.path.join(site_dir,'themes')
  modules = os.path.join(site_dir,'modules')
  chmod_walk(themes)
  chmod_walk(modules)
