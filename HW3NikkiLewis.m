
clear all; 
close all; 
clc
set(0, 'DefaultFigureVisible', 'on')

img=1; % Starting a counter for video frames

% formatting the data
doublifyingdata

load('Grayscale.mat')

% initializing cell arrays for looping through structure fields
% and formatting plots
Cam={{'Camera1'};{'Camera2'};{'Camera3'}};
subscr={{'a'};{'b'};{'c'};{'d'}};
style={{'-'};{'.'};{'-.'}};

% tracking the motion
MotionTrackHW3

% assembling the X matrix for SVD
assembleX

%% Perform SVD
SVD_HW3

%% Low Rank Approximations
for aprank=1:6;
    figure(9) 
    clf
    figure(10) 
    clf
for ipt=1:4;
    u=Results.(string(subscr(ipt))).u;
    s=Results.(string(subscr(ipt))).s;
    v=Results.(string(subscr(ipt))).v;

    LRankX=u(:,1:aprank)*s(1:aprank,1:aprank)*v(:,1:aprank).';
    
   for oo=1:size(LRankX,2)
        LRank(:,oo)=LRankX(:,oo)./max(abs(LRankX(:,oo)));
   end
   
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
        
        x=x./max(abs(x));
        y=y./max(abs(y));

        figure(9)
        subplot(2,2,ipt)
        plot(1:(length(y)),y,'k'+string(style(era))); hold on
        xlabel('Frame')
        ylabel('Normalized Displacement (pixels)')
        sgtitle('Y Displacement')
        grid on 
        
        figure(10)
        subplot(2,2,ipt)
        plot(1:(length(x)),x,'k'+string(style(era))); hold on
        xlabel('Frame')
        ylabel('Normalized Displacement (pixels)')
        sgtitle('X Displacement')
    end
    
        figure(9)
        subplot(2,2,ipt)
        c=0;
            v={{'r-'};{'r.'};{'r-.'}};
            for o1=2:2:6;
                c=c+1;
              
                plot(1:201,LRank(:,o1),string((v(c))))
            end
        xlim([0 201])
        sgtitle('Y Reconstruction')
        legend 1 2 3 1R 2R 3R  
        legend('Location','bestoutside')
        title('Motion '+string(ipt))
        xlabel('Time Frame')
        ylabel('Reconstructed Displacement (px)')
        
        figure(10)
        subplot(2,2,ipt)
        c=0;
            xlim([0 201])
            for o1=1:2:5;
                c=c+1;
            plot(1:201,LRank(:,o1),string((v(c))))
            end
    
        sgtitle('X Reconstruction')
        legend 1 2 3 1R 2R 3R 
        legend('Location','bestoutside')
        title('Motion '+string(ipt))
        xlabel('Time Frame')
        ylabel('Reconstructed Displacement (px)')
       
end
mkdir('Rank'+string(aprank)+'figures')
cd('Rank'+string(aprank)+'figures')
for ff=9:10;
    figure(ff)
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
saveas(gcf,'Rank'+string(aprank)+'figure'+string(ff)+'.png')
end

% the different values of the v' matrix represent the modal contributions to each degree of freedom 
cd ..
end
