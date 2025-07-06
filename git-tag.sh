git fetch --tags
current=$(git tag --sort=-creatordate | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | head -n 1)
if [[ -z "$current" ]]; then
  current="v0.0.0"
fi
echo "Current version: $current"

IFS='.' read -r -a parts <<< "${current#v}"
major=${parts[0]}
minor=${parts[1]}
patch=${parts[2]}

case "${{ github.event.inputs.bump }}" in
major) ((major++)); minor=0; patch=0 ;;
minor) ((minor++)); patch=0 ;;
patch|*) ((patch++)) ;;
esac

new_tag="v$major.$minor.$patch"
echo "New tag: $new_tag"

git tag -a "$new_tag" -m "Release $new_tag"

echo "::group::Git remote and status debug"
git remote -v
git status
git show-ref --tags
echo "::endgroup::"

echo "Pushing tag $new_tag"
git push origin "$new_tag" || {
echo "❌ Failed to push tag. Possibly due to permissions or detached HEAD.";
exit 1;
}