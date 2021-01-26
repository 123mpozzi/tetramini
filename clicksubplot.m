% Utilizzata per gestire i click sui subplot nel caso in cui si utilizzi
% lo script quality_control.m
% 
% Codice di base merito di:
% https://www.mathworks.com/matlabcentral/answers/172565-how-to-get-the-subplot-number-by-clicking-on-it
function  out = clicksubplot

    while 1 == 1
        w = waitforbuttonpress;
          switch w 
              case 1 % keyboard 
                  key = get(gcf,'currentcharacter'); 
                  if key==27 % (the Esc key) 
                      try; delete(h); end
                      out = 2;
                      break
                  end
              case 0 % mouse click 
                  mousept = get(gca,'currentPoint');
                  x = mousept(1,1);
                  y = mousept(1,2);
                  try; delete(h); end
                  
                  % Segnala il click all'utente
                  h = text(x,y,'\color{magenta} SCARTATO!','vert','middle','horiz','center');
                  
                  tags = get(gca, 'tag');
                  id_schema = str2num(tags(2));
                  id_scena = str2num(tags(1));
                  
                  load('analysis.mat', 'errors');
                  errors(id_scena, id_schema) = 1;
                  save('analysis.mat', 'errors');
                  out = 1;
          end
    end
end
  