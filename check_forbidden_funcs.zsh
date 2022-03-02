# **************************************************************************** #
#                                                                              #
#                                                         ::::::::             #
#    check_forbidden_funcs.zsh                          :+:    :+:             #
#                                                      +:+                     #
#    By: mvan-wij <mvan-wij@student.codam.nl>         +#+                      #
#                                                    +#+                       #
#    Created: 2022/03/01 19:01:18 by mvan-wij      #+#    #+#                  #
#    Updated: 2022/03/02 14:26:30 by mvan-wij      ########   odam.nl          #
#                                                                              #
# **************************************************************************** #

function list_include_item {
	local list=$1
	local item=$2
	if [[ $list =~ (^|[[:space:]])"$item"($|[[:space:]]) ]]; then
		return 0
	else
		return 1
	fi
}

function filter_out {
	local list_to_filter=$1
	local filters=$2
	for item in ${=list_to_filter}; do
		if `list_include_item $filters $item`; then
		else
			echo $item
		fi
	done
}

function check_forbidden_funcs() {
	if [ $# -eq 0 ]; then
		echo "Usage: check_forbidden_funcs <file> [name_filters...]"
	else
		local file=$1
		local names=$(nm $file)
		local defined_funcs=$(echo $names | egrep -e '^(\s|[0-9a-fA-F])* [Tt]' | egrep -o '[^ ]*$' | sort | uniq)
		local undefined_funcs=$(echo $names | egrep -e '^(\s|[0-9a-fA-F])* U' | egrep -o '[^ ]*$' | sort | uniq)
		local real_undefined_funcs=$(filter_out $undefined_funcs $defined_funcs)
		local filtered_funcs=$real_undefined_funcs
		if [ $# -eq 1 ]; then
			echo "\033[33mYou can specify additional (egrep) filters\033[0m" >&2
		else
			for filter in {2..$#}; do
				filtered_funcs=$(echo $filtered_funcs | egrep -v -e `eval echo '$'$filter`)
			done
		fi
		echo $filtered_funcs
	fi
}
