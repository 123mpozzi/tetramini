% Data un'immagine di schema in input, restituisce
% l'immagine labellizzata dei tetramini in output.
function out_labelled = etichetta_schema(image)
    image = rgb2gray(image);
    
    % Creo mask per filtrare  le sagome 
    mask=sauvola(image,[31 31]);

    % Pulisco la maschera
    mask=medfilt2(mask,[5 5]);

    % trovo componenti connesse
    labels=bwlabel(mask);

    % MIGLIORAMENTO
    % se si vuole migliorare il modo in cui viene scartato lo sfondo
    % bisognerebbe comunque fare restituire un'immagine labelizzata
    % le cui etichetta partono da 1! Oppure dovremmo calcolare
    % l'etichetta di partenza in ogni funzione che cicla le label.
    % Al momento questo script assume che la regione piu' grande sia
    % la prima (perche' di solito lo schema e' al centro e quindi la
    % prima regione processata e' lo sfondo) e quindi la evita,
    % e poi scala tutte le regioni con un -1 prima di restituirle.
    
    % Restituisco maschera senza la regione più grande
    out_labelled = labels-1;
end
