set +x
# Syntax check - Packer
# packer validate <template>
#
# With test syntax and configuration
# -syntax-only to not check configuration

echo "Syntax check: Packer Template"

echo 'xxxxxxxxxxxxxxxxx';echo 'Executing the Packer Syntax check:'
packer validate template.json

