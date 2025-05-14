.POSIX:
.SILENT:
.PHONY: install uninstall

install: txtconv.sh
	mkdir -p "${DESTDIR}${PREFIX}/bin"
	cp txtconv.sh "${DESTDIR}${PREFIX}/bin/txtconv"
	chmod a+x "${DESTDIR}${PREFIX}/bin/txtconv"

uninstall:
	rm -f "${DESTDIR}${PREFIX}/bin/txtconv"
