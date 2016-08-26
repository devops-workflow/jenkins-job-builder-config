#!/bin/bash
export XDG_CONFIG_HOME=$WORKSPACE
for RPM in $(ls -1 $WORKSPACE/pkg/*.rpm); do
  fileRPM=$(basename ${RPM})
  [[ $fileRPM =~ ^([-_a-zA-Z]*)[^0-9] ]] && nameRPM=${BASH_REMATCH[0]}
  if [ -z "$nameRPM" ]; then
    echo "ERROR: Cannot determine RPM basename of ${fileRPM}"
    exit 1
  fi
  if [ -f $WORKSPACE/pkg/${nameRPM}rpmlint.config ]; then
    cp -f $WORKSPACE/pkg/${nameRPM}rpmlint.config $WORKSPACE/rpmlint
  elif [ -f $WORKSPACE/pkg/rpmlint.config ]; then
    cp -f $WORKSPACE/pkg/rpmlint.config $WORKSPACE/rpmlint
  fi
  echo "Validating RPM file '${fileRPM}' with rpmlint:"
  rpmlint ${RPM}
done
