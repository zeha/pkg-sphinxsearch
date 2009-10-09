
# Rebuild all indexes daily and notify searchd.
@daily      sphinxsearch [ -x /usr/bin/indexer ] && /usr/bin/indexer --quiet --rotate --all

# Example for rotating only specific indexes (usually these would be part of
# a larger combined index).

# */5 * * * * sphinxsearch [ -x /usr/bin/indexer ] && /usr/bin/indexer --quiet --rotate postdelta threaddelta

