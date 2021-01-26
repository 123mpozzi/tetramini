% Quality control per calcolare e analizzare l'accuratezza dei risultati:
% testa l'algoritmo selezionando una scena alla volta ed eseguendo
% l'algoritmo stesso sulla scena selezionata e su tutti gli schemi
% forniteci (in totale 6).
%
% !!IMPORTANTE!!
% RICORDARSI di rinominare la scena 10 in 'P010.jpg' al posto di 'P10.jpg'
%
% AVVISO: Richiede una decina di minuti per ottenere
% i risultati completi (su tutte le scene forniteci),
% cambiare il valore della variabile 'amount' per diminuirne
% il tempo a discapito della completezza delle analisi.

close all;
clear;

resize_scale = 0.2; % scalo le immagini ad una grandezza inferiore
knn = class_knn(resize_scale); % Addestramento Classificatore


% SETTAGGI

% Numero di scene su cui provare gli schemi
% amount = 3; Esegue il programma sull'immagine numero 3
% amount = 4:7; Esegue il programma sulle immagini 4,5,6,7
% amount = [3,6,9]; Esegue il programma sulle immagini 3,6,9
amount = 1:10;
n_schemi = 6;  %numero totale di schemi, non va modificato
n_scene = size(amount,2);


% STATISTICHE DI ANALISI
output_size = [size(amount), n_schemi];
errors = zeros(size(amount,2), n_schemi); % matrice degli elementi scartati
save('analysis.mat', 'errors');


% QUALITY CONTROL
% Per ogni scena, prova tutti gli schemi su di essa e mostra i risultati
figH = figure(3);
shg;
for is = amount
    clf; % clear della figure
    
    scena = im2double(imread(strcat('Scene/P0', num2str(is),'.jpg')));
    scena = imresize(scena,resize_scale);
    
    % inizializza la finestra di output
    % Stampera' in prima riga la scena di riferimento
    % Mentre poi dividera principalmente i risultati sugli schemi in 2
    % colonne, ognuna composta da due colonne: lo schema in input e lo
    % schema restituito in output dal programma, con i tetramini reali.
    fin = 5; % figure index, dove andra' la prossima img plottata
    set(gcf, 'Position', get(0, 'Screensize'));
    subplot(4, 4, 1), imshow(scena), title(strcat('scena ', num2str(is)));
    subplot(4, 4, 3), imshow(scena), title(strcat('scena ', num2str(is)));
    
    for i=1:n_schemi % cicla tutti gli schemi
        sgtitle(strcat('Calcolo 6 output, aspetta qualche secondo... [', num2str(i), '/6]'))
        
        schema = im2double(imread(strcat('Schemi/S0',num2str(i),'.jpg')));
        schema = imresize(schema,resize_scale);

        % Individuo tetramini in immagine di SCHEMA
        label_schema = etichetta_schema(schema);
        % Individuo tetramini in immagine di SCENA
        label_scena = etichetta_scena(scena, knn);


        % Calcolo la correlazione tra un tetramino di schema e la sua
        % migliore corrispondenza significativa (che supera una certa soglia)
        % nella scena.
        % La migliore corrispondenza e' ottenuta attraverso l'analisi di 4 angoli
        % del tetramino di scena.
        % Ottengo lo schema risultante.
        schema_res = piazza_tetramino(label_schema, label_scena, schema, scena, 0);

        % Mostro scena e risultato
        % (salto la prima riga, offset = 4)
        subplot(4, 4, fin), imshow(schema),  title(strcat('schema ', num2str(i)));
        drawnow;
        subplot(4, 4, fin+1), imshow(schema_res), title(strcat('output ', num2str(i)));
        drawnow;
        set(gca,'tag',[num2str(is),num2str(i)]);
        fin = fin+2; % aggiorna index subplots
    end
    
    sgtitle('\color{magenta} ORA CLICCA GLI OUTPUT DA SCARTARE (e poi premi ESC)')
    while clicksubplot == 0
    end
end


% ANALISI DEI DATI
load('analysis.mat', 'errors');
n_errors = sum(sum(errors));
n_outputs = size(errors,1)*size(errors,2);
acc = 100-(100*n_errors/n_outputs); % accuracy

% Mostra gli output scartati su matrice, gli errori saranno in bianco.
clf;
shg;
titles = strcat('Output scartati in bianco. ACC=',num2str(acc), ' #errori=', num2str(n_errors));
subplot(1,1,1),imagesc(errors),axis image,title(titles);
colormap(hot(255)); % da imagesc in bianco e nero
xlabel('# Schema'),ylabel('# Scena');
grid on;
set(gca,'TickLength',[0 0]);
set(gca,'XTick',.5:1:n_schemi-0.5);
set(gca,'XTickLabel',1:n_schemi);
set(gca,'YTick',.5:1:n_scene-0.5);
set(gca,'YTickLabel',1:n_scene);
set(gca,'YDir','normal');

