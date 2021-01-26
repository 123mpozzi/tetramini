% Per ogni tetramino di schema, cerca la migliore corrispondenza
% presente in scena e successivamente la inserisce nello schema reale.
% Restituisce lo schema risultante, contenente i tetramini reali
% identificati dall'immagine di scena.
function schema = piazza_tetramino(label_schema, label_scena, schema, scena, debug)

    Tcorr = 0.825; % soglia di correlazione minima

    tot1 = max(label_schema(:));
    tot2 = max(label_scena(:));
    
    % Salva in una matrice i valori di correlazione tra il
    % tetramino di schema binarizzato (bw1) e ogni tetramino di
    % scena binarizzato (bw2).
    % tetramini schema -> indici riga, tetramini scena -> indici colonna
    % Inoltre vengono salvate anche scala e angolo di rotazione migliori
    % come dimensioni aggiuntive.
    bw1xbw2 = zeros(tot1,tot2,3);
    for j=1:tot1
        bw1 = label_schema==j; % seleziono tetramino in schema
        
        for k=1:tot2
            bw2 = label_scena==k; % seleziono tetramino in scena
            
            % Ottengo l'angolo e correlazione migliore tra bw2 e bw1
            [anglef, scalef, corr] = calcola_angolo(bw1,bw2,debug);
            

            % Salvo correlazione, scala e angolo
            bw1xbw2(j,k,1) = corr;
            bw1xbw2(j,k,2) = scalef;
            bw1xbw2(j,k,3) = anglef;
        end
    end
    
    
    % matches contiene i tetramini di schema come righe,
    % la prima colonna e' l'indice del miglior match per quella riga.
    % Per riempire matches si inizia dal massimo di tutta la matrice
    % bw1bw2 e si continua con il seguente massimo.
    matches = zeros(max(tot1,tot2), 4);
    for h = 1:max(tot1,tot2)
        maxmax = max(max(bw1xbw2(:,:,1)));
        
        % se non ci sono piu' massimi oppure non rispettano la
        % soglia, esco dal ciclo
        if maxmax == -1 || maxmax < Tcorr
            break
        end
        
        % Trovo le coord del massimo trovato.
        [i,j] = find(bw1xbw2 == maxmax);
        
        % Se ho due numeri uguali che sono il massimo, i e j saranno
        % degli array, in quel caso prendo il primo.
        i = i(1);
        j = j(1);
        
        % il tetramino j va in i
        % Inoltre salvo le informazioni legate (scale,angolo)
        matches(i,:) = [j squeeze(bw1xbw2(i,j,:))'];
        % Ho utilizzato un tetramino e quindi elimino
        % sia la riga dello schema, che la colonna del tetramino
        % impostandoli a -1
        bw1xbw2(i,:,:) = -ones(1,tot2,3);
        bw1xbw2(:,j,:) = -ones(tot1,1,3);
    end
    % matches ora avra' la prima colonna contenente i tetra di scena
    % da inserire
    
    
    % Itero matches e piazzo fisicamente il tetramino di scena
    % nello schema reale.
    for h = 1:size(matches,1)
        id_bw2 = matches(h,1); % id tetra di scena migliore
        
        if(id_bw2 > 0) % se e' un id valido
            bw1 = label_schema==h; % tetra di schema
            bw2_best = label_scena==id_bw2; % tetra di scena migliore
            corr_best = matches(h,2);
            scale_best = matches(h,3);
            angle_best = matches(h,4);


            % Ora RUOTO il tetramino reale al suo posto nello schema

            % Ritaglio il tetramino reale grazie alla maschera
            tetra_real = bw2_best.*scena;
            % Resizo e ruoto il tetramino reale
            tetra_real_res = imresize(tetra_real, scale_best);
            tetra_real_rot = imrotate(tetra_real_res, angle_best);

            % faccio spazio al tetra reale
            schema = schema-bw1;


            % Sposto il tetramino reale al posto giusto nello schema

            [yy, xx] = find(bw1); % trova coord maschera tetramino in schema
            row1 = min(yy);
            row2 = max(yy);
            col1 = min(xx);
            col2 = max(xx);
            [ww, zz] = find(tetra_real_rot(:,:,1)); % trova coord tetramino reale
            ww1 = min(ww);
            ww2 = max(ww);
            zz1 = min(zz);
            zz2 = max(zz);
            % Croppa la regione del tetramino reale
            rgb_crop = tetra_real_rot(row1+(ww1-row1):row2+(ww2-row2),col1+(zz1-col1):col2+(zz2-col2),1:3);

            
            % Inserisce nello schema la regione del tetramino reale

            % Prepara un'immagine nera della grandezza dello schema
            black = zeros(size(schema));
            % Sostituisce una parte con la regione del tetramino reale
            black(row1:ww2-ww1+row1,col1:zz2-zz1+col1,:) = rgb_crop;
            % Moltiplica lo schema con il negativo dell'immagine
            % e poi lo somma con l'immagine nera contenente il tetramino
            % reale
            schema = schema.*(1-bw1)+black;
        end
    end
end
