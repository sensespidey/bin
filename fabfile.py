import os
from fabric.api import run, env, task
from fabric.contrib.files import append

env.use_ssh_config = True
env.hosts = ['link', 'rnao-dev.org', 'dev2.rnao.ca', 'web1.rnao.ca',
'mail.rnao.ca', 'web3.rnao.ca', 'projects.rnao.ca', 'nquire.rnao.ca',
'myrnao.ca', 'zimbra.rnao.org', 'solr.rnao.ca']

env.hosts = ['myrnao.ca', 'solr.rnao.ca', 'link']

def hello(name="world"):
	print("Hello %s!" % name)

@task
def host_type():
  run('uname -a')

def read_key_file(key_file):
    key_file = os.path.expanduser(key_file)
    if not key_file.endswith('pub'):
        raise RuntimeWarning('Trying to push non-public part of key pair')
    with open(key_file) as f:
        return f.read()
 
@task
def push_key(key_file='~/.ssh/id_rsa.pub'):
    key_text = read_key_file(key_file)
    append('~/.ssh/authorized_keys', key_text)

@task
def update():
  run('sudo apt-get update && sudo apt-get dist-upgrade')

