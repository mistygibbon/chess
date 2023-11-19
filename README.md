# Chess game
A chess game that can be played at command line

## Project structure

- class Game: handles gameplay flow
  - Initialize board
  - Keep track of rounds
  - Manage history
- class Board
  - Handles storing of pieces data and location on the board
  - Move pieces
- class Piece
  - Stores data about chess piece such as type (pawn,knight,king,...) and side (white/black)
  - Define allowable movements

### Special cases
- Promotion
  - Need specific prompt to choose what type to promote to
- En passant
  - Need data on whether the pawn has moved double as its last move
- Castling
  - Need data on whether king or rook has moved
- Check

### Todo
- PGN, FEN import and export
- Display legal moves
- AI player
- Threefold repetition
- Insufficient material
- Halfmove rule
- Better input
