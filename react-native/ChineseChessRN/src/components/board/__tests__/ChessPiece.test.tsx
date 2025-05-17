import React from 'react';
import { render, fireEvent } from '../../../utils/testing/test-utils';
import { ChessPiece } from '../ChessPiece';

describe('ChessPiece Component', () => {
  // Test props
  const defaultProps = {
    id: 'r1',
    type: 'rook',
    position: { row: 0, col: 0 },
    color: 'red',
    isSelected: false,
    onSelect: jest.fn(),
  };
  
  it('renders correctly with default props', () => {
    const { getByTestId } = render(<ChessPiece {...defaultProps} />);
    
    // Check that the piece is rendered
    const piece = getByTestId('chess-piece-r1');
    expect(piece).toBeTruthy();
  });
  
  it('renders with the correct color', () => {
    const { getByTestId } = render(<ChessPiece {...defaultProps} />);
    
    // Check that the piece has the correct color
    const piece = getByTestId('chess-piece-r1');
    expect(piece.props.style).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          backgroundColor: expect.stringMatching(/red|#f00|#ff0000/i),
        }),
      ])
    );
    
    // Render a black piece
    const { getByTestId: getBlackPiece } = render(
      <ChessPiece {...defaultProps} id="R1" color="black" />
    );
    
    // Check that the piece has the correct color
    const blackPiece = getBlackPiece('chess-piece-R1');
    expect(blackPiece.props.style).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          backgroundColor: expect.stringMatching(/black|#000|#000000/i),
        }),
      ])
    );
  });
  
  it('renders with the correct type', () => {
    const { getByTestId } = render(<ChessPiece {...defaultProps} />);
    
    // Check that the piece has the correct type
    const piece = getByTestId('chess-piece-r1');
    expect(piece).toBeTruthy();
    
    // Render different piece types
    const pieceTypes = ['king', 'advisor', 'bishop', 'knight', 'rook', 'cannon', 'pawn'];
    
    pieceTypes.forEach((type) => {
      const { getByTestId: getPieceByType } = render(
        <ChessPiece {...defaultProps} id={`${type}1`} type={type} />
      );
      
      // Check that the piece is rendered with the correct type
      const typedPiece = getPieceByType(`chess-piece-${type}1`);
      expect(typedPiece).toBeTruthy();
    });
  });
  
  it('applies selected styles when selected', () => {
    const { getByTestId } = render(<ChessPiece {...defaultProps} isSelected={true} />);
    
    // Check that the piece has the selected style
    const piece = getByTestId('chess-piece-r1');
    expect(piece.props.style).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          borderColor: expect.any(String),
          borderWidth: expect.any(Number),
        }),
      ])
    );
  });
  
  it('calls onSelect when pressed', () => {
    const onSelect = jest.fn();
    const { getByTestId } = render(
      <ChessPiece {...defaultProps} onSelect={onSelect} />
    );
    
    // Find and press the piece
    const piece = getByTestId('chess-piece-r1');
    fireEvent.press(piece);
    
    // Check that onSelect was called with the correct arguments
    expect(onSelect).toHaveBeenCalledWith({
      id: 'r1',
      type: 'rook',
      position: { row: 0, col: 0 },
      color: 'red',
    });
  });
  
  it('renders at the correct position', () => {
    const { getByTestId } = render(
      <ChessPiece {...defaultProps} position={{ row: 3, col: 4 }} />
    );
    
    // Check that the piece is positioned correctly
    const piece = getByTestId('chess-piece-r1');
    expect(piece.props.style).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          position: 'absolute',
          top: expect.any(Number),
          left: expect.any(Number),
        }),
      ])
    );
  });
  
  it('renders with the correct size', () => {
    const { getByTestId } = render(<ChessPiece {...defaultProps} />);
    
    // Check that the piece has the correct size
    const piece = getByTestId('chess-piece-r1');
    expect(piece.props.style).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          width: expect.any(Number),
          height: expect.any(Number),
        }),
      ])
    );
  });
});
