% Data un'immagine di scena in input, restituisce
% l'immagine labellizzata dei tetramini in output.
function out_labeled = etichetta_scena(image, classifier_knn)

    h=fspecial('average',3);
    image= imfilter(image,h);

    [r,c,ch] = size(image);
    
    test_values = reshape(image,r*c,ch);

    % Etichette delle classi predette sui dati test_values
    test_predicted = predict(classifier_knn,test_values);
    predicted = reshape(test_predicted,r,c,1);

    % Cerco di staccare eventuali ombre dai tetramini
    predicted = imopen(predicted,strel('square',3));
    
    % Pulizia Maschera
    % Elimino piccole aree di regioni 8-connesse
    predicted = bwareaopen(predicted, 2000); 

    out_labeled = bwlabel(predicted);
end
