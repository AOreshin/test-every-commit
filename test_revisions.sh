WORKDIR=$1
TO_BRANCH=$2
FROM_BRANCH=$3
TEST_COMMAND=$4
BEFORE_TEST=$5
echo "Working directory: $WORKDIR"
cd "$WORKDIR" || exit 1
echo "Checking out branch $FROM_BRANCH"
git checkout -f "$FROM_BRANCH" || exit 1
echo "Executing $BEFORE_TEST"
(eval "$BEFORE_TEST") || exit 1
(git log --pretty=format:"%h" --reverse "$TO_BRANCH".."$FROM_BRANCH" || exit 1) |
  {
    while read revision || [ -n "$revision" ]; do
      git checkout -f "$revision" || exit 1
      eval "$TEST_COMMAND"
      STATUS=$?
      if [ $STATUS -ne 0 ]; then
        echo "Failed on $(git log --oneline -1)"
        exit 1
      fi
    done
    echo "Testing ended, checking out branch $FROM_BRANCH"
    git checkout "$FROM_BRANCH"
  } || exit 1
