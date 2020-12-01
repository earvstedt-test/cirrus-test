#! /usr/bin/env nix-shell
#! nix-shell -i bash -p git gnupg
set -euo pipefail

TMPDIR="$(mktemp -d -p /tmp)"
trap "rm -rf $TMPDIR" EXIT
cd $TMPDIR

echo "Fetching latest release"
git clone https://github.com/lightninglabs/loop 2> /dev/null
cd loop
latest=$(git describe --tags `git rev-list --tags --max-count=1`)
echo "Latest release is ${latest}"

# GPG verification
export GNUPGHOME=$TMPDIR
echo "Fetching Alex Bosworth's Key"
gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys DE23E73BFA8A0AD5587D2FCDE80D2F3F311FD87E 2> /dev/null
echo "Fetching Oliver Gugger's Key"
gpg --keyserver hkps://keys.openpgp.org --recv-keys F4FC70F07310028424EFC20A8E4256593F177720 2> /dev/null

echo "Verifying latest release"
git verify-tag ${latest}

echo "tag: ${latest}"
# The prefix option is necessary because GitHub prefixes the archive contents in this format
echo "sha256: $(git archive --format tar.gz --prefix=loop-${latest//v}/ ${latest} | sha256sum | cut -d\  -f1)"
