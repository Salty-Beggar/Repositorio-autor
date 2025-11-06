
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div id="TopHeader" class="horizontalSection">
        <div class="topHeaderSides">
            <div id="Title">
                Netflix
            </div>
            <div id="MainCategories">
                <div>Início</div>
                <div>Séries</div>
                <div>Filmes</div>
                <div>Novidades</div>
                <div>Minha lista</div>
            </div>
        </div>
        <div class="topHeaderSides">
            Right options
        </div>
    </div>

    <div id="SearchHeader" class="horizontalSection">
        <div class="topHeaderSides">
            <div id="FilmsTitle">
                Filme
            </div>
            <div id="Dropdown">
                <select name="dropdown" id="dropdown">
                    <option value="searchCategorization">Gêneros</option>
                    <option value="searchCategorization">Ano de lançamento</option>
                    <option value="searchCategorization">Boludos</option>
                </select>
            </div>
        </div>
        <div class="topHeaderSides">
            <div id="movieDisposalSelection">
                <button>a</button>
                <button>b</button>
            </div>
        </div>
    </div> 

    <?php
    $movieSections = ["Em alta", "Populares", "Filmes baseados em livros"];
    $movieRow = "<div class='movieRow'>";
    for ($i = 0; $i < 30; $i++) {
        $movieRow = $movieRow."<div class='movie'><img src='images/film.webp'></div>";
    }
    $movieRow = $movieRow."</div>";

    for ($i = 0; $i < 3; $i++) {
        echo "<div class='movieSection'>";
        echo $movieSections[$i];
        echo "</div>";
        echo $movieRow;
    }
    ?>

</body>
</html>