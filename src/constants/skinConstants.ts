/**
 * Constants for the Chinese Chess skins
 */
import { PIECE_TYPES } from './pieceConstants';

// Skin types
export const SKIN_TYPES = {
  WOODS: 'woods',
  STONES: 'stones',
};

// Skin configurations
export const SKINS = {
  [SKIN_TYPES.WOODS]: {
    name: 'Woods',
    boardImage: require('../assets/skins/woods/board.png'),
    pieces: {
      [PIECE_TYPES.RED_GENERAL]: require('../assets/skins/woods/red_general.png'),
      [PIECE_TYPES.RED_ADVISOR]: require('../assets/skins/woods/red_advisor.png'),
      [PIECE_TYPES.RED_ELEPHANT]: require('../assets/skins/woods/red_elephant.png'),
      [PIECE_TYPES.RED_HORSE]: require('../assets/skins/woods/red_horse.png'),
      [PIECE_TYPES.RED_CHARIOT]: require('../assets/skins/woods/red_chariot.png'),
      [PIECE_TYPES.RED_CANNON]: require('../assets/skins/woods/red_cannon.png'),
      [PIECE_TYPES.RED_PAWN]: require('../assets/skins/woods/red_pawn.png'),
      [PIECE_TYPES.BLACK_GENERAL]: require('../assets/skins/woods/black_general.png'),
      [PIECE_TYPES.BLACK_ADVISOR]: require('../assets/skins/woods/black_advisor.png'),
      [PIECE_TYPES.BLACK_ELEPHANT]: require('../assets/skins/woods/black_elephant.png'),
      [PIECE_TYPES.BLACK_HORSE]: require('../assets/skins/woods/black_horse.png'),
      [PIECE_TYPES.BLACK_CHARIOT]: require('../assets/skins/woods/black_chariot.png'),
      [PIECE_TYPES.BLACK_CANNON]: require('../assets/skins/woods/black_cannon.png'),
      [PIECE_TYPES.BLACK_PAWN]: require('../assets/skins/woods/black_pawn.png'),
    },
    selected: require('../assets/skins/woods/selected.png'),
    lastMove: require('../assets/skins/woods/last_move.png'),
    possibleMove: require('../assets/skins/woods/possible_move.png'),
  },
  [SKIN_TYPES.STONES]: {
    name: 'Stones',
    boardImage: require('../assets/skins/stones/board.png'),
    pieces: {
      [PIECE_TYPES.RED_GENERAL]: require('../assets/skins/stones/red_general.png'),
      [PIECE_TYPES.RED_ADVISOR]: require('../assets/skins/stones/red_advisor.png'),
      [PIECE_TYPES.RED_ELEPHANT]: require('../assets/skins/stones/red_elephant.png'),
      [PIECE_TYPES.RED_HORSE]: require('../assets/skins/stones/red_horse.png'),
      [PIECE_TYPES.RED_CHARIOT]: require('../assets/skins/stones/red_chariot.png'),
      [PIECE_TYPES.RED_CANNON]: require('../assets/skins/stones/red_cannon.png'),
      [PIECE_TYPES.RED_PAWN]: require('../assets/skins/stones/red_pawn.png'),
      [PIECE_TYPES.BLACK_GENERAL]: require('../assets/skins/stones/black_general.png'),
      [PIECE_TYPES.BLACK_ADVISOR]: require('../assets/skins/stones/black_advisor.png'),
      [PIECE_TYPES.BLACK_ELEPHANT]: require('../assets/skins/stones/black_elephant.png'),
      [PIECE_TYPES.BLACK_HORSE]: require('../assets/skins/stones/black_horse.png'),
      [PIECE_TYPES.BLACK_CHARIOT]: require('../assets/skins/stones/black_chariot.png'),
      [PIECE_TYPES.BLACK_CANNON]: require('../assets/skins/stones/black_cannon.png'),
      [PIECE_TYPES.BLACK_PAWN]: require('../assets/skins/stones/black_pawn.png'),
    },
    selected: require('../assets/skins/stones/selected.png'),
    lastMove: require('../assets/skins/stones/last_move.png'),
    possibleMove: require('../assets/skins/stones/possible_move.png'),
  },
};

// Get skin configuration
export const getSkin = (skinType: string) => {
  return SKINS[skinType] || SKINS[SKIN_TYPES.WOODS];
};

// Get piece image
export const getPieceImage = (skinType: string, pieceType: string) => {
  const skin = getSkin(skinType);
  return skin.pieces[pieceType];
};
