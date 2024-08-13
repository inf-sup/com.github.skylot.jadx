# build 参考

# build ninja
cd /project/linglong/sources/ninja.git
cmake -Bbuild
cmake --build build
ninja="$(pwd)/build/ninja"

# build REPLACE_BUILD_BUILD_NAME
cd /project/linglong/sources/REPLACE_BUILD_BUILD_NAME.git
cmake -Bbuild \
    -G Ninja \
    -DCMAKE_MAKE_PROGRAM=$ninja \
    -DCMAKE_CXX_FLAGS="-w" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_INSTALL_RPATH=$PREFIX/lib/$TRIPLET
cmake --build build
cmake --install build
