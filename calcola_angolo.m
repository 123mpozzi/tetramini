% Calcola l'angolo migliore di rotazione di bw2 per ottenere
% una rotazione simile a bw1 (bw1 e bw2 sono due maschere).
% Restituisce l'angolo migliore (best_angle),
% la scala utilizzata per passare da immagine di scena in schema (scalef),
% la correlazione migliore (corr_best).
function [best_angle, scalef, corr_best] = calcola_angolo(bw1, bw2, debug)

    % Ritaglio i tetramini dalle maschere
    cbw1 = crop_regione(bw1);  % bw1 schema
    cbw2 = crop_regione(bw2);  % bw2 scena
    
    % Prendo diametro e orientamento dei tetra ritagliati
    % Extrema e' utilizzato come orientamento per le figure quadrate
    stats = regionprops('table',cbw1,'MajorAxisLength','Orientation','Extrema');
    stats2 = regionprops('table',cbw2,'MajorAxisLength','Orientation','Extrema');
    
    % Cerca di riscalare l'immagine di scena come quella di schema
    scalef = stats.MajorAxisLength/stats2.MajorAxisLength;
    cbw2_res = imresize(cbw2, scalef);

    % Calcola l'angolo di rotazione delle figure quadrate
    ex1 = cell2mat(stats.Extrema);
    ex2 = cell2mat(stats2.Extrema);
    % Spiegazione perche' si usa Extrema per figure quadrate:
    % https://www.mathworks.com/matlabcentral/answers/97460-why-does-the-regionprops-command-not-return-the-correct-orientation-for-a-square-region
    sides = ex1(4,:) - ex1(6,:);
    or1 = rad2deg(atan(-sides(2)/sides(1))) ; % Note the 'minus' sign compensates for the inverted y-values in image coordinates
    sides = ex2(4,:) - ex2(6,:);
    or2 = rad2deg(atan(-sides(2)/sides(1))) ; % Note the 'minus' sign compensates for the inverted y-values in image coordinates

    % Per le figure normali basta l'Orientation
    angle = stats.Orientation-stats2.Orientation; %% RUOTA IL RESTO
    angles = [angle, angle+180];
    angle = or1-or2; %% RUOTA FIGURE QUADRATE
    angles = [angles, angle, angle+180]; % 2 angoli orientation, 2 angoli extrema
    angles = [angles, 0]; % i quadrati posizionati allo stesso modo davano problemi
    
    % Con debug=3 mostrera' un plot 3x2 contenente tetra di schema,
    % tetra di scena corrispondente identificato,
    % e poi ogni angolo provato, con un titolo in evidenza sul
    % miglior angolo.
    % (ATTENZIONE: tante finestre (40+) per ogni scena)
    if(debug == 3)
        figure();
        subplot(3,2,1),imshow(bw1),title('Tetra schema');
        subplot(3,2,2),imshow(bw2),title('Tetra scena corrispondente');
    end


    % Identifica la rotazione migliore
    % facendo una differenza tra l'immagine di schema
    % e i ritagli dopo aver applicati gli angoli
    siz = 800; % grandezza a cui verranno portate le immagini per fare la diff
    
    % Ora paddo le immagini per renderle ad una grandezza
    % uguale, per poter eseguire la sottrazione
    [hei, wid] = size(cbw1);
    cbw1 = padarray(cbw1, [siz-hei siz-wid], 0,'post');

    best = -1; % id angolo di rotazione migliore
    % La rotazione migliore sara' quella con correlazione maggiore
    corr_best = 0;
    for tr = 1:size(angles,2)
        % Scelto un id angolo, genero le immagini ruotate e le croppo
        rott = crop_regione(imrotate(cbw2_res, angles(tr)));

        % padding a dimensione standard
        [hei, wid] = size(rott);
        padd = padarray(rott, [siz-hei siz-wid], 0, 'post');

        % La soluzione migliore sara' quella con correlazione maggiore
        corr = corr2(cbw1,padd);
        if(corr > corr_best)
            best = tr;
            corr_best = corr;
        end

        % plotta la figura ottenuta dopo rotazione e crop
        if(debug == 3 && tr < size(angles,2))
            subplot(3,2,tr+2),imshow(rott),title(strcat('Angolo#', num2str(tr)));
        end
    end

    % aggiunge un titolo che mostra il miglior angolo di rotazione
    if(debug == 3)
        sgtitle(strcat('\color{magenta} Best is Angolo#', num2str(best)))
    end
    
    best_angle = angles(best);
end
