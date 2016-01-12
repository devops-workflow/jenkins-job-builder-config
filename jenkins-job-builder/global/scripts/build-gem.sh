set +x
pkg_gem=$1
if [ -f build.sh ]; then
  ./build.sh
else
  gem build ${pkg_gem}.gemspec
fi

