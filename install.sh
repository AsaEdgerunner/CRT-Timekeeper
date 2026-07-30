#!/usr/bin/env bash
# Timekeeper — installer for Linux (desktop launcher, no root required)
set -e

APP_NAME="CRT-Timekeeper"
APP_SLUG="crt-timekeeper"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/docs"
INSTALL_DIR="$HOME/.local/share/${APP_SLUG}"
DESKTOP_DIR="$HOME/.local/share/applications"
DESKTOP_FILE="${DESKTOP_DIR}/${APP_SLUG}.desktop"

echo "Installing ${APP_NAME}..."

mkdir -p "$INSTALL_DIR"
cp -f "$SRC_DIR/index.html" "$INSTALL_DIR/index.html"
cp -f "$SRC_DIR/icon.svg" "$INSTALL_DIR/icon.svg"

# Find a browser that supports --app (a frameless, chrome-less window)
BROWSER_BIN=""
for candidate in google-chrome google-chrome-stable chromium chromium-browser brave-browser microsoft-edge; do
  if command -v "$candidate" >/dev/null 2>&1; then
    BROWSER_BIN="$candidate"
    break
  fi
done

mkdir -p "$DESKTOP_DIR"

if [ -n "$BROWSER_BIN" ]; then
  EXEC_LINE="$BROWSER_BIN --app=file://${INSTALL_DIR}/index.html --name=${APP_NAME} --class=${APP_NAME}"
  echo "Using ${BROWSER_BIN} in app mode (no browser chrome)."
else
  EXEC_LINE="xdg-open file://${INSTALL_DIR}/index.html"
  echo "No Chromium-based browser found — falling back to your default browser."
  echo "For a proper borderless app window, install chromium, google-chrome, or brave-browser."
fi

cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=${APP_NAME}
Comment=Minimalist task time tracker
Exec=${EXEC_LINE}
Icon=${INSTALL_DIR}/icon.svg
Terminal=false
Categories=Utility;Office;
StartupWMClass=${APP_NAME}
EOF

chmod +x "$DESKTOP_FILE"

# Refresh the desktop database if available, so the app shows up immediately
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$DESKTOP_DIR" >/dev/null 2>&1 || true
fi

echo ""
echo "Done. ${APP_NAME} is installed at:"
echo "  ${INSTALL_DIR}"
echo ""
echo "You should now find '${APP_NAME}' in your application launcher / menu."
echo "You can also run it directly with:"
echo "  ${EXEC_LINE}"
