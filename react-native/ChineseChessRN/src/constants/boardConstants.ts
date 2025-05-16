/**
 * Constants for the Chinese Chess board
 */

// Board dimensions
export const BOARD_ROWS = 10;
export const BOARD_COLS = 9;

// Board positions
export const BOARD_POSITIONS = {
  // Palace corners for red side
  RED_PALACE_TOP_LEFT: { row: 7, col: 3 },
  RED_PALACE_TOP_RIGHT: { row: 7, col: 5 },
  RED_PALACE_BOTTOM_LEFT: { row: 9, col: 3 },
  RED_PALACE_BOTTOM_RIGHT: { row: 9, col: 5 },
  
  // Palace corners for black side
  BLACK_PALACE_TOP_LEFT: { row: 0, col: 3 },
  BLACK_PALACE_TOP_RIGHT: { row: 0, col: 5 },
  BLACK_PALACE_BOTTOM_LEFT: { row: 2, col: 3 },
  BLACK_PALACE_BOTTOM_RIGHT: { row: 2, col: 5 },
  
  // River positions
  RIVER_TOP: { row: 4, col: 0 },
  RIVER_BOTTOM: { row: 5, col: 0 },
};

// Board markings
export const BOARD_MARKINGS = {
  // Cannon positions
  RED_CANNON_LEFT: { row: 7, col: 1 },
  RED_CANNON_RIGHT: { row: 7, col: 7 },
  BLACK_CANNON_LEFT: { row: 2, col: 1 },
  BLACK_CANNON_RIGHT: { row: 2, col: 7 },
  
  // Soldier positions
  RED_SOLDIER_1: { row: 6, col: 0 },
  RED_SOLDIER_2: { row: 6, col: 2 },
  RED_SOLDIER_3: { row: 6, col: 4 },
  RED_SOLDIER_4: { row: 6, col: 6 },
  RED_SOLDIER_5: { row: 6, col: 8 },
  BLACK_SOLDIER_1: { row: 3, col: 0 },
  BLACK_SOLDIER_2: { row: 3, col: 2 },
  BLACK_SOLDIER_3: { row: 3, col: 4 },
  BLACK_SOLDIER_4: { row: 3, col: 6 },
  BLACK_SOLDIER_5: { row: 3, col: 8 },
};

// Default piece size (will be scaled based on board size)
export const DEFAULT_PIECE_SIZE = 58;

// Default board dimensions
export const DEFAULT_BOARD_WIDTH = 530;
export const DEFAULT_BOARD_HEIGHT = 586;

// Board padding
export const BOARD_PADDING = {
  TOP: 10,
  RIGHT: 10,
  BOTTOM: 10,
  LEFT: 10,
};

// Cell size calculation
export const getCellSize = (boardWidth: number) => {
  const cellWidth = (boardWidth - BOARD_PADDING.LEFT - BOARD_PADDING.RIGHT) / (BOARD_COLS - 1);
  return cellWidth;
};

// Position calculation
export const getPositionFromCoordinates = (row: number, col: number, cellSize: number, boardWidth: number, boardHeight: number) => {
  const x = BOARD_PADDING.LEFT + col * cellSize;
  const y = BOARD_PADDING.TOP + row * cellSize;
  
  return { x, y };
};

// Coordinate calculation from position
export const getCoordinatesFromPosition = (x: number, y: number, cellSize: number, boardWidth: number, boardHeight: number) => {
  const col = Math.round((x - BOARD_PADDING.LEFT) / cellSize);
  const row = Math.round((y - BOARD_PADDING.TOP) / cellSize);
  
  return { row, col };
};
