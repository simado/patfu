#!/bin/bash
set -x

apt-get update
apt-get -y install git rsync python3-sphinx

pwd ls -lah
export SOURCE_DATE_EPOCH=$(git log -1 --pretty=%ct)
 
##############
# BUILD DOCS #
##############
 
# Python Sphinx, configured with source/conf.py
# See https://www.sphinx-doc.org/
make clean
make html

#######################
# Update GitHub Pages #
#######################

git config --global user.name "${GITHUB_ACTOR}"
git config --global user.email "${GITHUB_ACTOR}@users.noreply.github.com"
 
docroot=`mktemp -d`
rsync -av "build/html/" "${docroot}/"
 
pushd "${docroot}"

git init
git remote add deploy "https://token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
git checkout -b gh-pages
 
# Adds .nojekyll file to the root to signal to GitHub that  
# directories that start with an underscore (_) can remain
touch .nojekyll
 
# Add README
cat > README.md <<EOF
# About
This is a github pages branch, used for displaying project information as a website using **GitHub Pages**.
If you're not using **Jekyll** theme, it's important to place the `.nojekyll` file in the root directory.
# Creating a clean gh-pages branch
This is the sequence of steps to follow to create a root `gh-pages` branch. The answer is used from this [link](https://gist.github.com/ramnathv/2227408).
```
cd /path/to/repo-name
git symbolic-ref HEAD refs/heads/gh-pages
rm .git/index
git clean -fdx
echo "My GitHub Page" > index.html
git add .
git commit -a -m "First pages commit"
git push origin gh-pages
```
Why do we need to do all this, instead of just calling `git branch gh-pages`. Well, if you are at master and you do `git branch gh-pages`, gh-pages will be based off master.
Here, the intention is to create a branch for github pages, which is typically not associated with the history of your repo (master and other branches) and hence the usage of git symbolic-ref. This creates a "root branch", which is one without a previous history.
Note that it is also called an orphan branch and `git checkout --orphan` will now do the same thing as the `git symbolic-ref` that was being done before.
EOF
 
# Copy the resulting html pages built from Sphinx to the gh-pages branch 
git add .
 
# Make a commit with changes and any new files
msg="Updating Docs for commit ${GITHUB_SHA} made on `date -d"@${SOURCE_DATE_EPOCH}" --iso-8601=seconds` from ${GITHUB_REF} by ${GITHUB_ACTOR}"
git commit -am "${msg}"
 
# overwrite the contents of the gh-pages branch on our github.com repo
git push deploy gh-pages --force
 
popd # return to main repo sandbox root
 
# exit cleanly
exit 0