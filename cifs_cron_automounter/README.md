# CIFS automounter

Usage, install scripts into /usr/local/etc/cifs_automount.sh

Add cronjob

```
*/10 * * * * /usr/local/etc/cifs_automount.sh >/dev/null 2>&1
```
