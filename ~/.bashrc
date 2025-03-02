cursor() {
  latest_cursor=$(ls -t ~/Downloads/cursor*.AppImage | head -n 1)
  if [[ -n "$latest_cursor" ]]; then
    cd /home/jake/Projects/  # Change directory before launching Cursor
    "$latest_cursor" --appimage-extract-and-run
  else
    echo "No Cursor AppImage found in ~/Downloads/"
  fi
} 