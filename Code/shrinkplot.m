pos=get(gca,'position');  % retrieve the current values
pos(3)=0.9*pos(3);        % try reducing width 10%
pos(4)=0.8*pos(4);    
set(gca,'position',pos);  % write the new values