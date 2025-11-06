
const canvas = document.getElementById("Canvas");

const colArray = [
    {
        x: 0, y: 80, width: 300, height: 50, type: 0
    },
    {
        x: 120, y: 190, width: 500, height: 50, type: 0
    },
    {
        x: 120, y: 190, width: 30, height: 220, type: 0
    },
    {
        x: 300, y: 320, width: 30, height: 200, type: 0
    },
    {
        x: 180, y: 320, width: 50, height: 20, type: 1, xMin: 150, xMax: 250, curDirection: 1
    },
    {
        x: 180, y: 380, width: 50, height: 20, type: 1, xMin: 150, xMax: 250, curDirection: -1
    },
];

let index = 0;
for (const i of colArray) {
    const newRect = document.createElementNS("http://www.w3.org/2000", "rect");
    newRect.setAttribute("x", i.x);
    newRect.setAttribute("y", i.y);
    newRect.setAttribute("width", i.width);
    newRect.setAttribute("height", i.height);
    if (i.type === 0) newRect.setAttribute("fill", "black");
    else newRect.setAttribute("fill", "green");
    canvas.appendChild(newRect);
    newRect.id = "collision_"+index.toString();
    canvas.innerHTML += "";
    index++;
}

index = 0;
for (const i of colArray) {
    i.tag = document.getElementById("collision_"+index.toString());
    index++;
}

const player = document.getElementById("Player");
let playing = false;

player.addEventListener("mousedown", () => {
    playing = true;
});

function reset() {
    playing = false;
    player.setAttribute("x", 10);
    player.setAttribute("y", 10);
}

addEventListener("mousemove", (e) => {
    if (playing) {
        let newX = e.clientX;
        let newY = e.clientY;

        player.setAttribute("x", newX-10);
        player.setAttribute("y", newY-10);
        
        for (const curCol of colArray) {
            if (newX <= curCol.x+curCol.width && newX >= curCol.x &&
                newY <= curCol.y+curCol.height && newY >= curCol.y) {
                reset();
            }
        }
    }
});

addEventListener("mouseup", () => {
    playing = false;
});

setInterval(() => {
    for (const i of colArray) {
        if (i.type === 1) {
            i.x += i.curDirection;
            if (i.x > i.xMax) i.curDirection = -1;
            if (i.x < i.xMin) i.curDirection = 1;
            i.tag.setAttribute("x", i.x);
        }
    }
}, 10);