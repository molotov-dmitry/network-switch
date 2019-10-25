.PHONY: all install

all:

install: /usr/local/bin/network-switch

### Executable =================================================================

/usr/local/bin:
	mkdir -p /usr/local/bin

/usr/local/bin/network-switch: /usr/local/bin network-switch.sh
	install network-switch.sh /usr/local/bin/network-switch

