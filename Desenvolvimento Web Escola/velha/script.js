
const cell_nothing = 0;
const cell_X = 1;
const cell_Y = 2;
const gameArr = [
    [0, 0, 0],
    [0, 0, 0],
    [0, 0, 0]
]

let turn = 0;
let lastStarter = cell_X;
let occupiedCells = 0;
let hasWon = false;
let isRunning = true;

function startGame(starterID) {
    turn = starterID;
    occupiedCells = 0;
    for (let i = 0; i < 3; i++) {
        for (let j = 0; j < 3; j++) {
            gameArr[i][j] = cell_nothing;
            cells.item(i).children.item(j).children.item(0).innerHTML = "";
        }
    }
    resultTag.innerText = "";
    hasWon = false;
    isRunning = true;
}

function markCell_turnBased(x, y) {
    const hasMarked = markCell(turn, x, y);
    if (hasMarked) turn = (turn == cell_X) ? cell_Y : cell_X;
}

function markCell(cellID, x, y) {
    if (gameArr[x][y] != cell_nothing) return false;
    cells.item(x).children.item(y).children.item(0).innerHTML = '<img src="'+((cellID == cell_X) ? "cellX.png" : "cellO.png")+'">';
    gameArr[x][y] = cellID;
    let isAligning = true;
    for (let i = 0; i < 3; i++) {
        console.log(gameArr[x][i]);
        console.log(cellID);
        if (gameArr[x][i] != cellID) {
            isAligning = false;
            break;
        }
    }
    if (isAligning) win(cellID);
    isAligning = true;
    for (let i = 0; i < 3; i++) {
        if (gameArr[i][y] != cellID) {
            isAligning = false;
            break;
        }
    }
    if (isAligning) win(cellID);
    if (x == y) {
        isAligning = true;
        for (let i = 0; i < 3; i++) {
            if (gameArr[i][i] != cellID) {
                isAligning = false;
                break;
            }
        }
        if (isAligning) win(cellID);
    }
    if (2-x == y) {
        isAligning = true;
        for (let i = 0; i < 3; i++) {
            if (gameArr[2-i][i] != cellID) {
                isAligning = false;
                break;
            }
        }
        if (isAligning) win(cellID);
    }

    occupiedCells++;
    if (occupiedCells == 9 && !hasWon) draw();

    return true;
}

const resultTag = document.getElementById("Results");
function win(cellID) {
    hasWon = true;
    isRunning = false;
    resultTag.innerText = (cellID == cell_X) ? "X ganhou!!" : "O ganhou!!";
}

function draw() {
    isRunning = false;
    resultTag.innerText = "Empatou!!";
}

const cells = document.getElementById("Game").children.item(0).children;
for (let i = 0; i < 3; i++) {
    for (let j = 0; j < 3; j++) {
        cells.item(i).children.item(j).children.item(0).addEventListener("click", () => {if (isRunning) markCell_turnBased(i, j)});
    }
}

startGame(lastStarter);
lastStarter = (lastStarter == cell_X) ? cell_Y : cell_X;

const resetButton = document.getElementById("Button_StartAgain").addEventListener("click", () => {
    startGame(lastStarter);
    lastStarter = (lastStarter == cell_X) ? cell_Y : cell_X;
});