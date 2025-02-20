#!/bin/sh

# -----------------------------------------------------------------------------
# 1) Install system dependencies and Rust
#    - Install build essentials and required libraries
#    - Install Rust if not available
# -----------------------------------------------------------------------------
# Check if running on Linux (specifically Debian/Ubuntu)
if [ "$(uname)" = "Linux" ]; then
    echo "${GREEN}Installing system dependencies...${NC}"
    sudo apt update
    sudo apt install -y build-essential pkg-config libssl-dev protobuf-compiler
fi

# Check and install Rust
if ! command -v rustc >/dev/null 2>&1; then
    echo "${GREEN}Installing Rust...${NC}"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    # Source cargo environment
    . "$HOME/.cargo/env"
fi

# Verify Rust installation
rustc --version || {
    echo "${ORANGE}Failed to verify Rust installation${NC}"
    exit 1
}

# -----------------------------------------------------------------------------
# 2) Define environment variables and colors for terminal output.
# -----------------------------------------------------------------------------
NEXUS_HOME="$HOME/.nexus"
GREEN='\033[1;32m'
ORANGE='\033[1;33m'
NC='\033[0m'  # No Color

# Ensure the $NEXUS_HOME directory exists.
[ -d "$NEXUS_HOME" ] || mkdir -p "$NEXUS_HOME"

# -----------------------------------------------------------------------------
# 3) Display a message if we're interactive (NONINTERACTIVE is not set) and the
#    $NODE_ID is not a 28-character ID. This is for Testnet II info.
# -----------------------------------------------------------------------------
if [ -z "$NONINTERACTIVE" ] && [ "${#NODE_ID}" -ne "28" ]; then
    echo ""
    echo "${ORANGE}The Nexus network is currently in Testnet II. You can now earn Nexus Points.${NC}"
    echo ""
fi

# -----------------------------------------------------------------------------
# 4) Prompt the user to agree to the Nexus Beta Terms of Use if we're in an
#    interactive mode (i.e., NONINTERACTIVE is not set) and no node-id file exists.
#    We explicitly read from /dev/tty to ensure user input is requested from the
#    terminal rather than the script's standard input.
# -----------------------------------------------------------------------------
while [ -z "$NONINTERACTIVE" ] && [ ! -f "$NEXUS_HOME/node-id" ]; do
    read -p "Do you agree to the Nexus Beta Terms of Use (https://nexus.xyz/terms-of-use)? (Y/n) " yn </dev/tty
    echo ""
    
    case $yn in
        [Nn]* ) 
            echo ""
            exit;;
        [Yy]* ) 
            echo ""
            break;;
        "" ) 
            echo ""
            break;;
        * ) 
            echo "Please answer yes or no."
            echo "";;
    esac
done

# -----------------------------------------------------------------------------
# 5) Check for 'git' availability. If not found, prompt the user to install it.
# -----------------------------------------------------------------------------
git --version 2>&1 >/dev/null
GIT_IS_AVAILABLE=$?
if [ "$GIT_IS_AVAILABLE" != 0 ]; then
  echo "Unable to find git. Please install it and try again."
  exit 1
fi

# -----------------------------------------------------------------------------
# 6) Clone or update the network-api repository in $NEXUS_HOME.
# -----------------------------------------------------------------------------
REPO_PATH="$NEXUS_HOME/network-api"
if [ -d "$REPO_PATH" ]; then
  echo "$REPO_PATH exists. Updating."
  (
    cd "$REPO_PATH" || exit
    git stash
    git fetch --tags
  )
else
  (
    cd "$NEXUS_HOME" || exit
    git clone https://github.com/nexus-xyz/network-api
  )
fi

# -----------------------------------------------------------------------------
# 7) Check out the latest tagged commit in the repository.
# -----------------------------------------------------------------------------
(
  cd "$REPO_PATH" || exit
  git -c advice.detachedHead=false checkout "$(git rev-list --tags --max-count=1)"
)

# -----------------------------------------------------------------------------
# 8) Set up protobuf configuration and build environment
# -----------------------------------------------------------------------------
(
  cd "$REPO_PATH/clients/cli" || exit
  
  # Create or update build.rs
  cat > build.rs << 'EOF'
fn main() -> Result<(), Box<dyn std::error::Error>> {
    tonic_build::configure()
        .protoc_arg("--experimental_allow_proto3_optional")
        .compile(
            &["proto/orchestrator.proto"],
            &["proto"],
        )?;
    Ok(())
}
EOF

  # Update Cargo.toml with necessary dependencies
  if ! grep -q "tonic-build" Cargo.toml; then
    echo '[build-dependencies]' >> Cargo.toml
    echo 'tonic-build = { version = "0.8", features = ["prost"] }' >> Cargo.toml
  fi

  # Clean any previous builds
  cargo clean

  # Run the CLI
  cargo run -r -- start --env beta
) < /dev/tty

# -----------------------------------------------------------------------------
# For local testing (e.g., staging mode), comment out the above cargo run line
# and uncomment the line below.
#
# echo "Current location: $(pwd)"
# (cd clients/cli &&   cargo run -r -- start --env beta
# )
# -----------------------------------------------------------------------------
