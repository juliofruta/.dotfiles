function pindown() {
  if [ -z "$1" ]; then
    echo "Usage: pindown <pinterest_url>"
    return 1
  fi

  local url="$1"
  echo "Fetching image from: $url"

  # Extract the image URL using grep
  local image_url=$(curl -sL "$url" | grep -o 'https://i.pinimg.com/[^"]*')

  if [ -z "$image_url" ]; then
    echo "Could not find image URL. The page structure might have changed or the URL is invalid."
    return 1
  fi

  # Get the first URL if multiple are found
  image_url=$(echo "$image_url" | head -n 1)

  echo "Found image URL: $image_url"
  echo "Downloading..."

  # Download the image, saving to the Downloads folder with a timestamp
  local filename="pinterest_$(date +%s).jpg"
  curl -s -o "$HOME/Downloads/$filename" "$image_url"

  if [ $? -eq 0 ]; then
    echo "Image saved to ~/Downloads/$filename"
  else
    echo "Download failed."
  fi
}
