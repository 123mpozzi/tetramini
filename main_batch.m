% Come il main, ma piu' in grande
% (effettua il lavoro che fa il main ma su piu' foto)
% Utilizzato per testare il programma.

close all;
clear;

resize_scale = 0.2; % scalo le immagini ad una grandezza inferiore
knn = class_knn(resize_scale); % Addestramento Classificatore


% SETTAGGI

% 0 non mostra finestre di debug
% >0 mostra le immagini originali di schema e scena e quelle etichettate
% 3 mostra la corrispondenza di ogni angolo per ogni tetramino
debug = 0;

% Numero di immagini su cui eseguire il programma, utile per testare
% si possono passare vettori oppure numeri scalari
% amount = 3; Esegue il programma sull'immagine numero 3
% amount = 4:7; Esegue il programma sulle immagini 4,5,6,7
% amount = [3,6,9]; Esegue il programma sulle immagini 3,6,9
amount = [2,3,9]; % -1 per 3 elementi random
if(amount == -1)
    amount = randperm(10,3);
end

% Modalita' per ciclare immagini multiple
cicle_mode = 0; % 0 ciclo scene, 1 ciclo schemi (piu' instabile)
if(cicle_mode == 1)
    scena = im2double(imread('Scene/P010.jpg')); % default scena
    scena = imresize(scena,resize_scale);
else
    schema = im2double(imread(strcat('Schemi/S01.jpg'))); % default schema
    schema = imresize(schema,resize_scale);
end


% CICLO OPERATIVO
for i=amount
    % Input programma
    if(cicle_mode == 1)
        schema = im2double(imread(strcat('Schemi/S0',num2str(i),'.jpg')));
        schema = imresize(schema,resize_scale);
    else
        scena = im2double(imread(strcat('Scene/P0', num2str(i),'.jpg')));
        scena = imresize(scena,resize_scale);
    end
    
    
    % Individuo tetramini in immagine di SCHEMA
    label_schema = etichetta_schema(schema);
    % Individuo tetramini in immagine di SCENA
    label_scena = etichetta_scena(scena, knn);
    
    
    % mostra immagini originali di schema e scena e quelle etichettate
    if(debug > 0)
        figure
        subplot(2, 2, 1), imshow(schema);
        subplot(2, 2, 2), imagesc(label_schema), axis image, title('Labeled Schema');
        subplot(2, 2, 3), imshow(scena);
        subplot(2, 2, 4), imagesc(label_scena), axis image, title('Labeled Scena');
    end
    
    % Calcolo la correlazione tra un tetramino di schema e la sua
    % migliore corrispondenza significativa (che supera una certa soglia)
    % nella scena.
    % La migliore corrispondenza e' ottenuta attraverso l'analisi di 4 angoli
    % del tetramino di scena.
    % Ottengo lo schema risultante.
    schema_res = piazza_tetramino(label_schema, label_scena, schema, scena, debug);
    
    % Mostro schema, scena e risultato
    figure
    subplot(2, 3, 1), imshow(schema), title('schema');
    subplot(2, 3, 3), imshow(scena), title('scena');
    subplot(2, 3, 5), imshow(schema_res), title('result');
end
