#!/usr/bin/env sh
#txtconv - convert from and to Windows format
set -eu

sponge() { set -- "$1" "$(mktemp)" && cat >"$2" && mv "$2" "$1"; }
fnmatch() { case "$2" in $1) return 0 ;; *) return 1 ;; esac }

encoding() {
	head -n1 2>/dev/null | sed -n '
        1s/^\xef\xbb\xbf.*\r$/bc/p;
        1s/^\xef\xbb\xbf.*$/b/p;
        1s/^.*\r$/c/p;
    '
}

sed_expr() {
	fnmatch '*b*' "$1" \
		&& printf '1s/^\\(\xef\xbb\xbf\\)\\{0,1\\}/\xef\xbb\xbf/;' \
		|| printf '1s/^\xef\xbb\xbf//;'
	fnmatch '*c*' "$1" \
		&& printf 's/\\(\r\\)\\{0,1\\}$/\r/;' \
		|| printf 's/\r$//;'
}

txtconv() {
	if [ -t 0 ] && [ $# -eq 0 ] || [ "${1-}" = --help ]; then
		printf '%s\n' \
			"Usage: $(basename "$0") [-b] [-c] <INFILE >OUTFILE" \
			"   or: $(basename "$0") [-b] [-c] -i FILE..." \
			"   or: $(basename "$0") -p <INFILE" \
			"" \
			"Options:" \
			"  -b   Ensure a UTF-8 BOM is present" \
			"  -c   Ensure every line ends with a carriage return" \
			"  -i   Edits file 'in place' (moves temp file back)" \
			"  -p   Print options to restore file to current state" \
			"" \
			"Omitting -b or -c removes the BOM or CR respectively."
		exit
	fi
	opts=""
	inplace=false
	while getopts 'pbci' OPT "$@"; do
		case "$OPT" in
		p) encoding && exit "$?" ;;
		b) opts="${opts}b" ;;
		c) opts="${opts}c" ;;
		i) inplace=true ;;
		esac
	done
	shift $(($OPTIND - 1))
	if "$inplace"; then
		case "$(sed --help 2>&1 || :)" in
		*"-i extension"*)
			sed -i '' "$(sed_expr "$opts")" "$@"
			;;
		*"-i[SUFFIX]"*)
			sed -i "$(sed_expr "$opts")" "$@"
			;;
		*)
			for x in "$@"; do
				<"$x" sed "$(sed_expr "$opts")" | sponge "$x"
			done
			;;

		esac
	else
		sed "$(sed_expr "$opts")"
	fi
}

txtconv "$@"
