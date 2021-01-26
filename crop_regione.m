% Ritaglia la regione di interesse di una maschera binaria contenente un
% oggetto e la restituisce.
function regione=crop_regione(mask)
    % Trovo coordinate della regione (es: tetramino)
    [y,x] = find(mask);
    
    % ritaglio la regione in base alle coordinate
    regione = mask(min(y):max(y),min(x):max(x));
end
