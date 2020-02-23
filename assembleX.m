for ipt=1:4;
X=[];

    for era=1:3;
         %% Removing DC Offset from Data (due to camera movement)
        x=detrend(storedpoints.(string(Cam(era))).(string(subscr(ipt)))(1,:));
        y=detrend(storedpoints.(string(Cam(era))).(string(subscr(ipt)))(2,:));

        if era==3;
        x=detrend(storedpoints.(string(Cam(era))).(string(subscr(ipt)))(2,:));
        y=detrend(storedpoints.(string(Cam(era))).(string(subscr(ipt)))(1,:));
        
        end
        
        subplot(2,2,ipt)
        %% clipping time histories 
            if ipt==1 && era==2;
                x=x(50:250);
                y=y(50:250);
            elseif ipt==2 && era~=2
                x=x(99:299);
                y=y(99:299);
            elseif ipt==3 && era==2;
                x=x(31:231);
                y=y(31:231);
            elseif ipt==3 && era==3;
                x=x(72:272);
                y=y(72:272);
            elseif ipt==4 && era==2;
                x=x(9:209);
                y=y(9:209);
            else
                x=x(1:201);
                y=y(1:201);
            end
        %% Normalizing data
        x=x./max(abs(x));
        y=y./max(abs(y));
        X=[X;x;y];
    
        %% Plotting stuff
        figure(1)
        subplot(2,2,ipt)
        plot(1:(length(y)),y,'k'+string(style(era))); hold on
        xlabel('Frame')
        ylabel('Normalized Displacement (pixels)')
        sgtitle('Y Displacement')
        xlim([0 201])
        
        figure(2)
        subplot(2,2,ipt)
        plot(1:(length(x)),x,'k'+string(style(era))); hold on
        xlabel('Frame')
        ylabel('Normalized Displacement (pixels)')
        sgtitle('X Displacement')
        xlim([0 201])
        grid on 
       
        
    
    end
    Xs.(string(subscr(ipt)))(:,:)=X'; % storing the X array in a structure
    
        figure(1)
        subplot(2,2,ipt)
        legend 1 2 3  
        title('Motion '+string(ipt))
         legend('Location','bestoutside')
        figure(2)
        subplot(2,2,ipt)
        legend 1 2 3  
        title('Motion '+string(ipt))
         legend('Location','bestoutside')
end
