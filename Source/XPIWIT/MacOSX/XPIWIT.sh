 #!/bin/sh
 appname=`basename $0 | sed s,\.sh$,,`

 dirname=`dirname $0`
 tmp="${dirname#?}"

 if [ "${dirname%$tmp}" != "/" ]; then
 dirname=$PWD/$dirname
 fi
 DYLD_LIBRARY_PATH=$dirname:$dirname/lib:$dirname/platforms:$DYLD_LIBRARY_PATH
 export DYLD_LIBRARY_PATH
 $dirname/$appname "$@"
