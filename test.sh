set -eu

die() { if [ "$#" -gt 0 ]; then printf "%s\n" "$*" >&2; fi && exit 1; }

txtconv() {
	sh ./txtconv.sh "$@"
}

[ "$(printf '\n' | txtconv -p)" = '' ] \
	|| die "Did not recognize Unix format"

[ "$(printf '\xef\xbb\xbf' | txtconv -p)" = b ] \
	|| die "Did not recognize BOM"

[ "$(printf '\r\n' | txtconv -p)" = c ] \
	|| die "Did not recognize CRLF"

[ "$(printf '\xef\xbb\xbf\r\n' | txtconv -p)" = bc ] \
	|| die "Did not recognize BOM+CRLF"

tmp="$(mktemp)"
printf "some\ntest\nlines\n" >"$tmp"

[ "$(<"$tmp" txtconv | txtconv -p)" = '' ] \
	|| die "NOOP on Unix format failed"

[ "$(<"$tmp" txtconv -b | txtconv -p)" = b ] \
	|| die "Adding BOM failed"

[ "$(<"$tmp" txtconv -c | txtconv -p)" = c ] \
	|| die "Adding CR failed"

[ "$(<"$tmp" txtconv -bc | txtconv -p)" = bc ] \
	|| die "Adding CR and BOM failed"

txtconv -ib "$tmp"
[ "$(<"$tmp" txtconv -p)" = b ] \
	|| die "Adding BOM in-place failed"

txtconv -ic "$tmp"
[ "$(<"$tmp" txtconv -p)" = c ] \
	|| die "Adding CR in-place failed"

txtconv -ibc "$tmp"
[ "$(<"$tmp" txtconv -p)" = bc ] \
	|| die "Adding CR in-place failed"

txtconv -i "$tmp"
[ "$(<"$tmp" txtconv -p)" = '' ] \
	|| die "Removing CR and BOM in-place failed"
