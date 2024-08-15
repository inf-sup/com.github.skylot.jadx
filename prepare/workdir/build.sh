# jdk 17
cd /project/linglong/sources
tar -xf openjdk-17.0.2_linux-x64_bin.tar.gz -C .
export JAVA_HOME="/project/linglong/sources/jdk-17.0.2"
# tools path
jdeps=$JAVA_HOME/bin/jdeps
jlink=$JAVA_HOME/bin/jlink
# jre dir
jre=$PREFIX/lib/jre
# gradle home
export GRADLE_USER_HOME=/project/linglong/sources/gradle

# build jadx
cd /project/linglong/sources/jadx.git
export "JADX_VERSION=1.5.0"
sed -i 's#\(distributionUrl\)=\([^=]*\)#\1=file\\:///project/linglong/sources/gradle-8.7-bin.zip#' gradle/wrapper/gradle-wrapper.properties
tar -zxf /project/gradle.tar.gz -C $(dirname $GRADLE_USER_HOME)
while IFS= read -r line; do
    pre="$GRADLE_USER_HOME/caches/modules-2"
    dir="$pre/$(dirname $line)"
    name=$(basename $line)
    mkdir -p $dir
    cp "../$name" "$dir/$name"
done < "/project/res.list"
./gradlew dist --offline
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
jd=$($jdeps -q --multi-release 17 --ignore-missing-deps --print-module-deps $JAVA_HOME/jmods build/jadx/lib/jadx-$JADX_VERSION-all.jar)
$jlink --module-path $JAVA_HOME/jmods --add-modules $jd --output $jre
