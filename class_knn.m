% IMPORTANTE: controllare che le due immagini
% tetramini.jpg e sfondo.jpg non siano state compresse per qualche motivo
% Le grandezza sono le seguenti:
% tetramini.jpg 4379x58 441 KB
% sfondo.jpg 11847x299 5292 KB
% (queste due immagini sono state create a partire dalle due sole immagini
% di training forniteci)
% 
% Restituisce il classificatore knn utilizzato per individuare
% i tetramini nell'immagine di scena e permettere la creazione
% dell'immagine binarizzata.
function [classifier_knn] = class_knn(resize_scale)

    % Carico Dati di Training  e gli srotolo in 2D

    tetramini=im2double(imread('tetramini.jpg'));
    tetramini=imresize(tetramini,resize_scale);
    [r,c,ch]=size(tetramini);

    tetramini=reshape(tetramini,r*c,ch);
    rs= size(tetramini,1);

    
    sfondo=im2double(imread('sfondo.jpg'));
    sfondo=imresize(sfondo,resize_scale);
    [r,c,ch]=size(sfondo);

    sfondo=reshape(sfondo,r*c,ch);
    rns= size(sfondo,1);


    % Concateno dati Tetramini e Sfondo
    train_values = [tetramini;sfondo];

    % Etichetto ogni tripletta di train_values
    % le prime rs righe sono Tetramini etichettate 1
    % le altre rns righe sono Sfondo etichettate 0
    train_labels=[ones(rs,1); zeros(rns,1)];


    % Classificatore KNN con k-vicini
    % se il mio pixel cade in una regione maggiormente popolata da 
    % una certa classe allora viene assegnato a quella classe
    classifier_knn = fitcknn(train_values , train_labels, 'NumNeighbors',3);
end
