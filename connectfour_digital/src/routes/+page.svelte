<script>
  // Color palette and theme
  const COLOR_PRIMARY = "#1976D2"; // Blue (player 1)
  const COLOR_SECONDARY = "#FFC107"; // Yellow (player 2)
  const GRID_COLS = 7;
  const GRID_ROWS = 6;

  // PUBLIC_INTERFACE
  function createEmptyGrid() {
    // 0: empty, 1: player 1, 2: player 2
    return Array.from({length: GRID_ROWS}, () => Array(GRID_COLS).fill(0));
  }

  let grid = createEmptyGrid();
  let currentPlayer = 1; // 1 (blue) starts
  let winner = null;
  let winningCells = [];
  let isDropping = false; // disables input during animation
  // For disc drop animation - track which cell is animating during a move
  let animatingDisc = {row: -1, col: -1, player: null};

  // Returns first available row for the given column (bottom to top)
  // PUBLIC_INTERFACE
  function getAvailableRow(col) {
    for (let row = GRID_ROWS - 1; row >= 0; row--) {
      if (grid[row][col] === 0) return row;
    }
    return -1;
  }

  // PUBLIC_INTERFACE
  function dropDisc(col) {
    if (isDropping || winner) return;
    const row = getAvailableRow(col);
    if (row === -1) return; // full column

    // Start animation for this position
    isDropping = true;
    animatingDisc = { row: 0, col, player: currentPlayer }; // start drop at row 0
    dropRow = row;
    dropCol = col;

    animateDiscDrop(0, row, col, currentPlayer);
  }

  // PUBLIC_INTERFACE
  function animateDiscDrop(step, targetRow, col, player) {
    // Duration per cell drop (ms):
    const dropSpeed = 60;
    if (step < targetRow) {
      animatingDisc = { row: step, col, player };
      setTimeout(() => animateDiscDrop(step + 1, targetRow, col, player), dropSpeed);
    } else {
      // On final position
      animatingDisc = { row: targetRow, col, player };
      setTimeout(() => {
        grid[targetRow][col] = player;
        animatingDisc = { row: -1, col: -1, player: null };
        checkWin(targetRow, col, player);
        if (!winner) currentPlayer = currentPlayer === 1 ? 2 : 1;
        isDropping = false;
      }, dropSpeed);
    }
  }

  // PUBLIC_INTERFACE
  function checkWin(row, col, player) {
    // Check all directions: horizontal, vertical, diagonal /
    let directions = [
      { dr: 0, dc: 1 },   // horizontal
      { dr: 1, dc: 0 },   // vertical
      { dr: 1, dc: 1 },   // diagonal \
      { dr: 1, dc: -1 }   // diagonal /
    ];

    for (let {dr, dc} of directions) {
      let cells = [{row, col}];
      // Look one way
      for (let s = 1; s < 4; s++) {
        let r = row + dr * s, c = col + dc * s;
        if (r < 0 || r >= GRID_ROWS || c < 0 || c >= GRID_COLS) break;
        if (grid[r][c] === player) cells.push({row: r, col: c});
        else break;
      }
      // Other way
      for (let s = 1; s < 4; s++) {
        let r = row - dr * s, c = col - dc * s;
        if (r < 0 || r >= GRID_ROWS || c < 0 || c >= GRID_COLS) break;
        if (grid[r][c] === player) cells.push({row: r, col: c});
        else break;
      }
      if (cells.length >= 4) {
        winner = player;
        winningCells = cells;
        return;
      }
    }
    // Check draw (no empty cell)
    if (grid.flat().every(cell => cell !== 0)) {
      winner = 0; // draw
    }
  }

  // PUBLIC_INTERFACE
  function isWinCell(row, col) {
    return winner && winningCells.some(c => c.row === row && c.col === col);
  }

  // PUBLIC_INTERFACE
  function resetGame() {
    grid = createEmptyGrid();
    currentPlayer = 1;
    winner = null;
    winningCells = [];
    isDropping = false;
    animatingDisc = {row: -1, col: -1, player: null};
  }

  // PUBLIC_INTERFACE
  function playerColor(player) {
    return player === 1 ? COLOR_PRIMARY : COLOR_SECONDARY;
  }

  // Accessibility: describe the game state
  $: statusMessage = winner === 1
    ? "Blue wins!"
    : winner === 2
      ? "Yellow wins!"
      : winner === 0
        ? "It's a draw!"
        : `Turn: ${currentPlayer === 1 ? "Blue" : "Yellow"}`;

  // For highlighting drop columns
  let hoveredCol = -1;
</script>

<style>
  .container {
    min-height: 100vh;
    display: flex; flex-direction: column;
    justify-content: center; align-items: center;
    background: #f6f9fb;
    font-family: 'Inter', Arial, sans-serif;
    padding: 1.5rem;
  }
  .turn-indicator {
    margin-bottom: 1.4rem;
    font-size: 1.6rem;
    font-weight: 600;
    text-align: center;
    letter-spacing: 0.04em;
    color: #222;
    display: flex;
    align-items: center;
    gap: 0.9rem;
  }
  .disc-sample {
    width: 1.12em;
    height: 1.12em;
    display: inline-block;
    border-radius: 50%;
    border: 2px solid #fff;
    box-shadow: 0 2px 6px rgba(0,0,0,0.13);
    margin-right: 0.15em;
    vertical-align: middle;
  }
  .grid {
    background: #1976D2;
    border-radius: 22px;
    box-shadow: 0 8px 24px rgba(30,70,140,0.13);
    padding: 1.3rem;
    display: grid;
    grid-template-columns: repeat(7, 54px);
    grid-template-rows: repeat(6, 54px);
    gap: 8px;
    position: relative;
  }
  .cell {
    width: 54px; height: 54px;
    background: #e3ebf5;
    border-radius: 50%;
    position: relative;
    box-shadow: 0 2px 9px rgba(25, 120, 210, 0.08);
    display: flex; align-items: center; justify-content: center;
    cursor: pointer;
    transition: background 0.16s;
    border: 2.3px solid #c2d3f5;
  }
  .cell[data-hover] {
    box-shadow: 0 0 0 3px #ffc10755;
    background: #fdf6e6;
  }
  .cell[data-win="true"] {
    box-shadow: 0 0 0 4px #D32F2F, 0 3px 11px #D32F2F44;
    z-index: 3;
  }
  .disc {
    width: 100%;
    height: 100%;
    border-radius: 50%;
    border: 2px solid #fff;
    box-shadow: 0 4px 8px rgba(80,70,40,0.13);
    transition: background 0.17s, box-shadow 0.18s;
    position: absolute;
    left: 0; top: 0;
    pointer-events: none;
  }
  .disc.p1 { background: #1976D2; }
  .disc.p2 { background: #FFC107; }
  .disc.animating {
    will-change: transform, top;
    z-index: 2;
    transition: transform 0.13s linear;
  }
  .overlay-winner {
    position: absolute; left: 0; right: 0; top: 0; bottom: 0;
    display: flex; align-items: center; justify-content: center;
    background: rgba(246,249,251,0.66);
    font-size: 2.3rem;
    font-weight: 700;
    color: #d32f2f;
    letter-spacing: 0.07em;
    border-radius: 22px;
    animation: fadeIn 0.4s ease;
    z-index: 20;
  }
  @keyframes fadeIn {
    from { opacity: 0 }
    to { opacity: 1 }
  }
  .reset-btn {
    margin-top: 2rem;
    background: #d32f2f;
    color: #fff;
    border: none;
    outline: none;
    border-radius: 20px;
    font-size: 1.11rem;
    font-weight: 500;
    padding: 0.62em 1.3em;
    box-shadow: 0 2px 10px #d3342f22;
    cursor: pointer;
    letter-spacing: 0.06em;
    transition: background .15s;
  }
  .reset-btn:hover, .reset-btn:focus {
    background: #b71c1c;
  }
  @media (max-width:500px) {
    .container {
      padding: 0.5rem;
    }
    .grid {
      padding: 0.4rem;
      grid-template-columns: repeat(7, 8vw);
      grid-template-rows: repeat(6, 8vw);
      gap: 3vw;
    }
    .cell {
      width: 8vw; height: 8vw;
    }
  }
</style>

<div class="container">
  <div class="turn-indicator" aria-live="polite">
    {#if !winner}
      <span
        class="disc-sample"
        style="background:{currentPlayer === 1 ? COLOR_PRIMARY : COLOR_SECONDARY};border-color:#fff"
        aria-label="Current player's disc"></span>
      {currentPlayer === 1 ? "Blue's turn" : "Yellow's turn"}
    {:else}
      {statusMessage}
    {/if}
  </div>
  <div class="grid"
    on:mouseleave={() => hoveredCol = -1}
    style="position:relative"
    aria-label="Connect Four grid"
    role="grid"
    tabindex="0">
    {#each Array(GRID_ROWS) as _rowIdx, rowIdx (rowIdx)}
      {#each Array(GRID_COLS) as _colIdx, colIdx (colIdx)}
        <div
          class="cell"
          data-win={isWinCell(rowIdx, colIdx)}
          data-hover={hoveredCol === colIdx && !winner && !isDropping}
          aria-colindex={colIdx+1}
          aria-rowindex={rowIdx+1}
          role="gridcell"
          tabindex="0"
          on:mouseenter={() => hoveredCol = colIdx}
          on:focus={() => hoveredCol = colIdx}
          on:mouseleave={() => hoveredCol = -1}
          on:blur={() => hoveredCol = -1}
          on:click={() => dropDisc(colIdx)}
          on:keydown={(e) => {
            if (e.key === "Enter" || e.key === " ") dropDisc(colIdx)
          }}
        >
          {#if grid[rowIdx][colIdx] !== 0}
            <div class="disc p{grid[rowIdx][colIdx]}" style="background:{playerColor(grid[rowIdx][colIdx])}"></div>
          {/if}
          {#if
            animatingDisc.col === colIdx &&
            animatingDisc.player !== null &&
            animatingDisc.row === rowIdx
          }
            <div
              class="disc animating p{animatingDisc.player}"
              style="background:{playerColor(animatingDisc.player)}; transform: translateY(-10%) scale(1.1); box-shadow:0 8px 18px #1976d233;"
            ></div>
          {/if}
        </div>
      {/each}
    {/each}
    {#if winner !== null}
      <div class="overlay-winner" role="alert">
        {statusMessage}
      </div>
    {/if}
  </div>
  <button class="reset-btn" type="button" on:click={resetGame}>Reset Game</button>
</div>
