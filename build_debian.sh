lnav_VERSION=$1
BUILD_VERSION=$2
ARCH=${3:-amd64}  # Default to amd64 if no architecture specified

if [ -z "$lnav_VERSION" ] || [ -z "$BUILD_VERSION" ]; then
    echo "Usage: $0 <lnav_version> <build_version> [architecture]"
    echo "Example: $0 0.14.1 1 arm64"
    echo "Example: $0 0.14.1 1 all    # Build for all architectures"
    echo "Supported architectures: amd64, arm64, all"
    exit 1
fi

# Function to map Debian architecture to the lnav release name.
# The musl builds are fully static, so the package has no runtime dependencies.
get_lnav_release() {
    local arch=$1
    case "$arch" in
        "amd64")
            echo "lnav-${lnav_VERSION}-linux-musl-x86_64"
            ;;
        "arm64")
            echo "lnav-${lnav_VERSION}-linux-musl-arm64"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Function to build for a specific architecture
build_architecture() {
    local build_arch=$1
    local lnav_release

    lnav_release=$(get_lnav_release "$build_arch")
    if [ -z "$lnav_release" ]; then
        echo "❌ Unsupported architecture: $build_arch"
        echo "Supported architectures: amd64, arm64"
        return 1
    fi

    echo "Building for architecture: $build_arch using $lnav_release"

    # Clean up any previous builds for this architecture
    rm -rf "$lnav_release" || true
    rm -f "${lnav_release}.zip" || true

    # Download and extract lnav binary for this architecture
    if ! wget "https://github.com/tstack/lnav/releases/download/v${lnav_VERSION}/${lnav_release}.zip"; then
        echo "❌ Failed to download lnav binary for $build_arch"
        return 1
    fi

    # lnav zips nest everything in lnav-<version>/ (lnav, lnav.1, README,
    # NEWS.md); extract into a per-release directory and flatten that level
    mkdir -p "$lnav_release"
    if ! unzip -q -j "${lnav_release}.zip" -d "$lnav_release"; then
        echo "❌ Failed to extract lnav binary for $build_arch"
        return 1
    fi

    rm -f "${lnav_release}.zip"

    if [ ! -f "$lnav_release/lnav" ] || [ ! -f "$lnav_release/lnav.1" ]; then
        echo "❌ Unexpected zip layout: $lnav_release/lnav or lnav.1 not found"
        return 1
    fi

    # One package for every suite: upstream ships one binary per architecture,
    # so only the old ~<suite> version suffix ever differed. The fixed ~griffo
    # keeps it below the distro's own build of the same version.
    FULL_VERSION="$lnav_VERSION-${BUILD_VERSION}~griffo_${build_arch}"
    echo "  Building $FULL_VERSION"

    if ! docker build . -t "lnav-$build_arch" \
        --build-arg lnav_VERSION="$lnav_VERSION" \
        --build-arg BUILD_VERSION="$BUILD_VERSION" \
        --build-arg FULL_VERSION="$FULL_VERSION" \
        --build-arg ARCH="$build_arch" \
        --build-arg LNAV_RELEASE="$lnav_release"; then
        echo "❌ Failed to build Docker image for $build_arch"
        return 1
    fi

    id="$(docker create "lnav-$build_arch")"
    if ! docker cp "$id:/lnav_$FULL_VERSION.deb" - > "./lnav_$FULL_VERSION.deb"; then
        echo "❌ Failed to extract .deb package for $build_arch"
        return 1
    fi

    if ! tar -xf "./lnav_$FULL_VERSION.deb"; then
        echo "❌ Failed to extract .deb contents for $build_arch"
        return 1
    fi

    # Clean up extracted directory
    rm -rf "$lnav_release" || true

    echo "✅ Successfully built for $build_arch"
    return 0
}

# Main build logic
if [ "$ARCH" = "all" ]; then
    echo "🚀 Building lnav $lnav_VERSION-$BUILD_VERSION for all supported architectures..."
    echo ""

    # All supported architectures (upstream publishes x86_64 and arm64 only)
    ARCHITECTURES=("amd64" "arm64")

    for build_arch in "${ARCHITECTURES[@]}"; do
        echo "==========================================="
        echo "Building for architecture: $build_arch"
        echo "==========================================="

        if ! build_architecture "$build_arch"; then
            echo "❌ Failed to build for $build_arch"
            exit 1
        fi

        echo ""
    done

    echo "🎉 All architectures built successfully!"
    echo "Generated packages:"
    ls -la lnav_*.deb
else
    # Build for single architecture
    if ! build_architecture "$ARCH"; then
        exit 1
    fi
fi
