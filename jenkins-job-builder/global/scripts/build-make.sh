set +x
if [ -f build.sh ]; then
  ./build.sh
else
  make clean
  make
fi

