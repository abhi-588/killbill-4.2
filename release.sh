# Prepare a release:
#   * Update the NEWS file
#   * Commit all pending changes
#   * Do the release
set -e

# Make sure we're up-to-date
git pull

LAST_NEWS_VERSION=$(head -1 NEWS)
NEXT_VERSION=`grep -E '<version>([0-9]+\.[0-9]+\.[0-9]+)-SNAPSHOT</version>' pom.xml | sed 's/[\t \n]*<version>\(.*\)-SNAPSHOT<\/version>[\t \n]*/\1/'`

echo "Enter the NEWS changelog for version $NEXT_VERSION and hit ctrl-d when done (ctrl-c to abort)"
original_news_message=$(cat)

# Indent it
news_message=$(echo "$original_news_message" | sed 's/^/    /g')

if [ "$LAST_NEWS_VERSION" = "$NEXT_VERSION" ]; then
  previous_news=$(cat NEWS | sed '1d')
  echo -e "$NEXT_VERSION\n$news_message\n$previous_news" > NEWS
else
  previous_news=$(cat NEWS)
  echo -e "$NEXT_VERSION\n$news_message\n\n$previous_news" > NEWS
fi

# Add to git
git add -p
git commit -s -m "pom.xml: updates for release $NEXT_VERSION

$original_news_message"

# Make sure we can push before the release
git push

# Do the release
echo "Running: mvn release:clean" && \
mvn release:clean && \
echo "Running: mvn release:prepare" && \
mvn release:prepare && \
echo "Running: mvn release:perform" && \
mvn release:perform && \
echo "Running mvn nexus-staging:release -Psonatype-oss-release" && \
cd target/checkout ; mvn nexus-staging:release -Psonatype-oss-release