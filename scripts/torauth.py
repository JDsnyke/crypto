#!/usr/bin/env python3

## Taken from https://stackoverflow.com/questions/48054399/get-the-hashed-tor-password-automated-in-python

import os, hashlib, binascii, codecs

secret = os.environ['APP_TOR_PROXY_PASSWORD']
indicator = chr(96)
salt = "%s%s" % (os.urandom(8), indicator)  #this will be working
c = ord(indicator)
EXPBIAS = 6
count = (16+(c&15)) << ((c>>4) + EXPBIAS)
d = hashlib.sha1()
tmp = salt[:8] + secret
slen = len(tmp)
while count:
    if count > slen:
        d.update(tmp.encode('utf-8'))
        count -= slen
    else:
        d.update(tmp[:count].encode('utf-8'))
        count = 0
hashed = d.digest()
saltRes = binascii.b2a_hex(salt[:8].encode('utf-8')).upper().decode()
indicatorRes = binascii.b2a_hex(indicator.encode('utf-8')).upper().decode()
torhashRes = binascii.b2a_hex(hashed).upper().decode()
hashedControlPassword = '16:' + str(saltRes) + str(indicatorRes) + str(torhashRes)
print(hashedControlPassword)