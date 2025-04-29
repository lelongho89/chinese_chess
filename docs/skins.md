# Chinese Chess Skin System

## Overview

The Chinese Chess game supports multiple skins for the chess board and pieces. Currently, there are two skins available:

1. **Woods** - A wooden board with traditional Chinese chess pieces
2. **Stones** - A stone-themed board with stone-like chess pieces

## Skin Configuration

Each skin is defined by a configuration file (`config.json`) in its respective folder under `assets/skins/`. The configuration file specifies the dimensions of the board, the size of the pieces, and the file names of the board and piece images.

### Configuration Format

```json
{
  "width": 521,
  "height": 577,
  "size": 57,
  "offset": {
    "dx": 4,
    "dy": 3
  },
  "board": "board.jpg",
  "red": {
    "K": "rk.png",
    "A": "ra.png",
    "B": "rb.png",
    "C": "rc.png",
    "N": "rn.png",
    "R": "rr.png",
    "P": "rp.png"
  },
  "black": {
    "k": "bk.png",
    "a": "ba.png",
    "b": "bb.png",
    "c": "bc.png",
    "n": "bn.png",
    "r": "br.png",
    "p": "bp.png"
  }
}
```

### Configuration Parameters

- `width`: The width of the board image in pixels
- `height`: The height of the board image in pixels
- `size`: The size of each chess piece in pixels
- `offset`: The offset of the first chess piece from the top-left corner of the board
- `board`: The file name of the board image
- `red`: A mapping of red piece codes to their image file names
- `black`: A mapping of black piece codes to their image file names

## Adding a New Skin

To add a new skin:

1. Create a new folder under `assets/skins/` with a descriptive name (e.g., `metal`)
2. Add the board image and piece images to the folder
3. Create a `config.json` file in the folder with the appropriate configuration
4. Update the `lib/setting.dart` file to include the new skin in the skin selection UI
5. Update the `lib/models/game_setting.dart` file to include the new skin in the default options

## Optimizing Skin Assets

All skin assets should be optimized for performance:

1. Board images should be JPEG format with a quality of 60-80%
2. Piece images should be PNG format with appropriate compression
3. All images should be sized appropriately for the game board

## Testing Skin Changes

When making changes to the skin system or adding new skins, be sure to test:

1. Skin switching functionality in the settings page
2. Proper rendering of the board and pieces with each skin
3. Performance on both iOS and Android devices

## Implementation Details

The skin system is implemented through the following classes:

- `ChessSkin`: Manages the loading and rendering of skin assets
- `GameSetting`: Stores the user's skin preference
- `GameManager`: Handles skin changes and notifies components to update

When the user changes the skin in the settings page, the `GameManager` creates a new `ChessSkin` instance and notifies all components to update through the `GameLoadEvent` event.
