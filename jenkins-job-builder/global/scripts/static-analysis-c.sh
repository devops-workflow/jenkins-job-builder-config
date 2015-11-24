set +x
# Static Analysis Checks - C/C++
# Tools - Coverage
# Tools - Security:
# Tools
# - cppcheck
# - splint

echo 'xxxxxxxxxxxxxxxxx';echo 'Executing the C/C++ Static Analysis testing:'
cppcheck --xml-version=2 --enable=warning,performance,style . 2> cppcheck-result.xml

