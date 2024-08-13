# install packages
install_pkg=$(realpath "./install_pkg.sh")
include_pkg=''
exclude_pkg=''
bash $install_pkg -i -d $(realpath 'linglong/sources') -p $PREFIX/jdk -I \"$include_pkg\" -E \"$exclude_pkg\"
export LD_LIBRARY_PATH=$PREFIX/lib/$TRIPLET:$LD_LIBRARY_PATH

# java home when building
export JAVA_HOME=$PREFIX/jdk/lib/jvm/java-11-openjdk-amd64
# jre runtime
jre=$PREFIX/lib/jre
# tools path
jdeps=$JAVA_HOME/bin/jdeps
jlink=$JAVA_HOME/bin/jlink
# gradle home
export GRADLE_USER_HOME=/project/linglong/sources/gradle

# build jadx
cd /project/linglong/sources/jadx.git
export "JADX_VERSION=1.5.0"
sed -i 's#\(distributionUrl\)=\([^=]*\)#\1=https\\://mirrors.cloud.tencent.com/gradle/gradle-8.7-bin.zip#' gradle/wrapper/gradle-wrapper.properties
./gradlew dist
cp -r build/jadx/* $PREFIX
sed -i "s|#!/usr/bin/env sh|#!/usr/bin/env sh\nJAVA_HOME=$jre|" $PREFIX/bin/jadx-gui

# desktop
mkdir -p $PREFIX/share/application
{
    echo "[Desktop Entry]"
    echo "Exec=jadx-gui"
    echo "Terminal=false"
    echo "Type=Application"
    echo "Comment=Dex to Java decompiler"
    echo "Icon=jadx"
    echo "Name=jadx"
} >$PREFIX/share/application/jadx.desktop
icon_target=$PREFIX/share/icons/hicolor
icon_source=jadx-gui/src/main/resources/logos
icon_name=jadx
mkdir -p $icon_target/scalable/apps
ls $icon_source | grep .svg | xargs -I{} cp $icon_source/{} $icon_target/scalable/apps/$icon_name.svg
ls $icon_source | grep px.png | sed "s#^.*[^0-9]\([0-9]*\)px[^.]*\.\([^.]*\)\$#$icon_target/\1x\1/apps#" | xargs mkdir -p
ls $icon_source | grep px.png | sed "s#^.*[^0-9]\([0-9]*\)px[^.]*\.\([^.]*\)\$#$icon_source/\0 $icon_target/\1x\1/apps/$icon_name.\2#" | xargs -n 2 cp

# jre
jd=$($jdeps -q --multi-release 11 --ignore-missing-deps --print-module-deps $JAVA_HOME/jmods build/jadx/lib/jadx-$JADX_VERSION-all.jar)
$jlink --module-path $JAVA_HOME/jmods --add-modules $jd --output $jre
cp $JAVA_HOME/lib/server/libjvm.so $jre/lib/server/libjvm.so

# uninstall dev packages
bash $install_pkg -u -r '.*'
