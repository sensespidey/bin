#!/usr/bin/perl

# first, create the base multisite dir for the new-site-shortname:
svn mkdir https://svn.ashoka-dev.org/<deploy-target>/<new-site-shortname>

# then check out a working copy of the new site:
cd /tmp (or some other directory you've created to hold these things, temporarily.. i use ~/multisite)
svn co https://svn.ashoka-dev.org/<deploy-target>/<new-site-shortname>
cd <new-site-shortname>

# create repository space for the new site
svn mkdir public
svn mkdir private

# seed the settings.php.tpl, any modules/themes the site will need customized, 
# and a private/dev_*.dump.mysql
svn copy https://svn.ashoka-dev.org/vendor/drupal/core/4.7.x/sites/default/settings.php public/settings.php.tpl

svn copy https://svn.ashoka-dev.org/vendor/drupal/core/4.7.x/database/database.4.0.mysql private/dev_<new-site-shortname>.dump.mysql

# finally, commit these changes in a single operation
svn commit -m "created <new-site-shortname> multisite tree, per ticket:xxx"

## BIG STEP 2
# update the DEVCORE working copy (on dev)
cd /home/webadmin/ashoka.ashoka-dev.org
echo 'new-site-shortname.ashoka-dev.org    https://svn.ashoka-dev.org/<deploy-target>/<new-site-shortname>/public' >> externals.def
svn propset svn:externals -F externals.def public/sites
svn update

# setup the database, and seed it with data:
mysql -u root -p mysql

mysql> CREATE DATABASE dev_<new-site-shortname>;
mysql> GRANT ALL ON dev_<new-site-shortname>.* to dev@localhost;
mysql> FLUSH PRIVILEGES;
mysql> ^D

mysql -u dev -p dev_<new-site-shortname> < ~/multisite/<new-site-shortname>/private/dev_<new-site-shortname>.dump.mysql

# configure the settings.php file to connect the db user/pass/dbname:
cd public/sites/<new-site-shortname>
cp settings.php.tpl settings.php
vim settings.php

# next step: setting up apache2 config files ;)
# add a vhost file
cd /etc/apache2/sites-available
cp ashoka <new-site-shortname>
vim <new-site-shortname>

# with contents like:
# --------------------------
# <new-site-shortname>.ashoka-dev.org
# --------------------------
<VirtualHost 64.84.32.103:80>
        DocumentRoot /home/webadmin/ashoka.ashoka-dev.org/public/
        ServerName <new-site-shortname>.ashoka-dev.org
        <Directory /home/webadmin/ashoka.ashoka-dev.org/public>
          AllowOverride All
          Options Indexes FollowSymLinks MultiViews ExecCGI Includes
          Order allow,deny
          allow from all
        </Directory>
        ErrorLog /home/webadmin/ashoka.ashoka-dev.org/logs/<new-site-shortname>.error_log
        CustomLog /home/webadmin/ashoka.ashoka-dev.org/logs/<new-site-shortname>.access_log combined
</VirtualHost>

# and finally, enable the site and restart apache:
sudo a2ensite <new-site-shortname>
sudo /etc/init.d/apache2 reload

