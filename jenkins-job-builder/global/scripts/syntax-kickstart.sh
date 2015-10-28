set +x
# Syntax check - Kickstart
# ksvalidator -e <file.ks>
#
# ksvalidator is in package pykickstart

echo "Syntax check: Kickstart"

echo 'xxxxxxxxxxxxxxxxx';echo 'Executing the Kickstart Syntax check:'
failed=0
for file in $(find . -name '*.ks' -type f); do
  ksvalidator -e $file 2>&1
  if [ "$?" -eq 1 ]; then
    echo "Kickstart syntax check failed: $file"
    failed=1
  fi
done
if [ $failed -eq 1 ]; then
  exit 1
fi

