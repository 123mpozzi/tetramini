% Script principale di utilizzo del programma
% Prende in input due immagini:
% - un'immagine di uno schema/puzzle composto da tetramini
% - un'immagine di una scena con diversi tetramini che potrebbero
%   essere utilizzati per riempire lo schema
% L'output sara' l'immagine di schema con i tetramini reali posizionati
% al suo interno, presi e ritagliati dall'immagine di scena.
% Non e' detto che nell'immagine di scena siano presenti tutti
% i tetramini necessari per riempire lo schema.
% L'output sara' mostrato in una finestra contenente anche gli input
% e le immagini di input labellizzate.

close all;
clear;


% INPUT
% setto le immagini da utilizzare
scena = im2double(imread('Scene/P010.jpg'));
schema = im2double(imread(strcat('Schemi/S06.jpg')));


% SETTAGGI
resize_scale = 0.2; % grandezza con cui scalare le immagini
knn = class_knn(resize_scale); % Addestramento Classificatore


% ALGORITMI

% scalo le immagini ad una grandezza inferiore
scena = imresize(scena,resize_scale);
schema = imresize(schema,resize_scale);

% Individuo tetramini in immagine di SCHEMA
label_schema = etichetta_schema(schema);
% Individuo tetramini in immagine di SCENA
label_scena = etichetta_scena(scena, knn);

% Calcolo la correlazione tra un tetramino di schema e la sua
% migliore corrispondenza significativa (che supera una certa soglia)
% nella scena.
% La migliore corrispondenza e' ottenuta attraverso l'analisi di 5 angoli
% del tetramino di scena.
% Ottengo lo schema risultante.
schema_res = piazza_tetramino(label_schema, label_scena, schema, scena, 0);


% OUTPUT
% Mostro schema, scena e risultato
% e anche le maschere labelizzate
figure
subplot(2, 3, 1), imshow(schema), title('schema');
subplot(2, 3, 2), imshow(schema_res), title('OUTPUT');
subplot(2, 3, 3), imshow(scena), title('scena');
subplot(2, 3, 4), imagesc(label_schema), axis image, title('Labeled Schema');
subplot(2, 3, 6), imagesc(label_scena), axis image, title('Labeled Scena');
