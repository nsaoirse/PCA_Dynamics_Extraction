
% • (test 1)
% Ideal case: Consider a small displacement of the mass in the z direction and the ensuing
% oscillations. In this case, the entire motion is in the z directions with simple harmonic motion being
% observed (camN 1.mat where N=1,2,3).

% • (test 2) 
% noisy case: Repeat the ideal case experiment, but this time, introduce camera shake into the
% video recording. This should make it more difficult to extract the simple harmonic motion. But if the
% shake isn’t too bad, the dynamics will still be extracted with the PCA algorithms. (camN 2.mat where N=1,2,3)

% • (test 3) 
% horizontal displacement: In this case, the mass is released off-center so as to produce motion
% in the x?y plane as well as the z direction. Thus there is both a pendulum motion and a simple harmonic
% oscillations. See what the PCA tells us about the system. (camN 3.mat where N=1,2,3)

% • (test 4) 
% horizontal displacement and rotation: In this case, the mass is released off-center and
% rotates so as to produce motion in the x?y plane, rotation as well as the z direction. Thus there is both
% a pendulum motion and a simple harmonic oscillations. See what the PCA tells us about the system.
% (camN 4.mat where N=1,2,3)

clear all; 
close all; 
clc
set(0, 'DefaultFigureVisible', 'on')
x=linspace(0,1,25);
t=linspace(0,2,50);

[T,X]=meshgrid(t,x); 

img=1;
showtracking='soo';
load('Grayscale.mat')

Cam={{'Camera1'};{'Camera2'};{'Camera3'}};

subscr={{'a'};{'b'};{'c'};{'d'}};
style={{'-'};{'.'};{'-.'}};
regions.Camera1.a=[320 220 20 50];
regions.Camera1.b=[315 290 25 50];
regions.Camera1.c=[320 280 20 50];
regions.Camera1.d=[370 265 50 15];

regions.Camera2.a=[260 265 25 50];
regions.Camera2.b=[295 335 35 50];
regions.Camera2.c=[238 285 25 50];
regions.Camera2.d=[210 225 100 80];

regions.Camera3.a=[310 260 75 23];
regions.Camera3.b=[340 245 75 23];
regions.Camera3.c=[350 210 75 23];
regions.Camera3.d=[350 210 40 50];

img=1;
for ipt=1:4;

    for era=1:3;
    
    
        
    if showtracking=='yes';
    figure
    hold on;
    end

    currset=(string(Cam(era)))+(','+string(subscr(ipt)));
    If=Camera.(string(Cam(era))).(string(subscr(ipt)))(:,:,1);

    if showtracking=='yes';
    imshow(If)
    F(img) = getframe(gcf);
              img=img+1;
    end

    %%
    reg=regions.(string(Cam(era))).(string(subscr(ipt)))(1,:);
%%

    regionsObj = detectMSERFeatures(If,'ROI',reg);

    [features, validPtsObj] = extractFeatures(If, regionsObj);

    if showtracking=='yes';
        
        If2=insertShape(If,'Rectangle',reg,'Color','red');
        imshow(If2); hold on;
        plot(regionsObj,'showPixelList',true,'showEllipses',false);
        title(currset)
       
        F(img) = getframe(gcf);
              img=img+1;
    end

        trackedpoints=validPtsObj.Location;
        tracker = vision.PointTracker('MaxBidirectionalError',3,'NumPyramidLevels',6);
        initialize(tracker,trackedpoints,If);

        [~,~,m]=size(Camera.(string(Cam(era))).(string(subscr(ipt))));
        title(currset)
        c=0;
        for im=1:1:m;
            c=c+1;
              Icurr=Camera.(string(Cam(era))).(string(subscr(ipt)))(:,:,im);
              
              if showtracking=='yes';
              imshow(Icurr);
     
              end
              
              [points,validity,score] = tracker(Icurr);

              if sum(validity)<=3 || (ipt==4 &&c==10) || (ipt==2 &&c==30);
                  
                  reg=([xavg(im-1)- reg(3)/2  yavg(im-1)-reg(4)/2 reg(3) reg(4)]);
                  if  era==3 || sum(validity)<=1 ;
                  reg=([xavg(im-1)- reg(3)/2  yavg(im-1)-reg(4)/2 reg(3) reg(4)*1.12]);
                  end
                    regionsObj = detectMSERFeatures(Icurr,'ROI',reg,'MaxAreaVariation',3);

                    [features, validPtsObj] = extractFeatures(Icurr, regionsObj);
                    If2=insertShape(Icurr,'Rectangle',reg,'Color','red');
                    
                    if showtracking=='yes';
                    imshow(If2); hold on;

                    plot(regionsObj,'showPixelList',true,'showEllipses',false);
                    F(img) = getframe(gcf);
                    img=img+1;    
                    
                    
                    end     
                    
                    trackedpoints=validPtsObj.Location;

                    tracker = vision.PointTracker('MaxBidirectionalError',2,'NumPyramidLevels',14);
                    initialize(tracker,trackedpoints,Icurr);
                    [points,validity,score] = tracker(Icurr);
                c=0;
              end
              
              xavg(im)=sum(points(:,1).*score)./sum(score);

              yavg(im)=sum(points(:,2).*score)./sum(score);

              reg=regions.(string(Cam(era))).(string(subscr(ipt)))(1,:);

              out = insertMarker(Icurr,points(validity, :),'+');
        
              if showtracking=='yes';
              imshow(out); drawnow
              F(img) = getframe(gcf);
              img=img+1;
              end
              
        end
        
        storedpoints.(string(Cam(era))).(string(subscr(ipt)))=[xavg;yavg];
             if showtracking=='yes';
        plot(xavg,yavg)
        title(currset)
        F(img) = getframe(gcf);
        img=img+1;
             end
    end
    
end
% writerObj = VideoWriter('myVideo.avi');
%   writerObj.FrameRate = 10;
%   % set the seconds per image
% % open the video writer
% open(writerObj);
% % write the frames to the video
% for i=1:length(F)
%     % convert the image to a frame
%     frame = F(i) ;    
%     writeVideo(writerObj, frame);
% end
% % close the writer object
% close(writerObj);
rbgb={{'r'},{'g'},{'b'}};
img=1;
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
        
        x=x./max(abs(x));
        y=y./max(abs(y));

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
       
        
    X=[X;x;y];
    
    end
    Xs.(string(subscr(ipt)))(:,:)=X';
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


for ipt=1:4;
        
%% SVD 
DataRank(ipt,:)=rank(Xs.(string(subscr(ipt))))
DataRange(ipt,:)=range(Xs.(string(subscr(ipt))));
DataNull(ipt,:,:)=null(Xs.(string(subscr(ipt))));
[m,n]=size(Xs.(string(subscr(ipt)))); % compute data size
mn=mean(Xs.(string(subscr(ipt))),1); % compute mean for each column

Xs.(string(subscr(ipt)))=Xs.(string(subscr(ipt)))-repmat(mn',1,201)'; % subtract mean
[u,s,v]=svd(Xs.(string(subscr(ipt)))/sqrt(n-1),'econ'); % perform the SVD
lambda=diag(s).^2; % produce diagonal variances

% T=v*Xs.(string(subscr(ipt)));
figure(2+ipt)

subplot(5,3,[1:3,4:6])
waterfall(u')
view([45,30])
xlabel('Time Frame')
ylabel('Mode Shape [SVD]')
yticks(1:6)
title('Orthogonal Mode Shapes')
shrinkplot
subplot(5,3,[7:9])
plot(1:size(s,1),diag(s).^2);
xlabel('Mode')
xticks(1:6)
ylabel('Energy')
title('Power by Orthogonal Mode')
shrinkplot

sgtitle('Test Case ' + string(ipt))

subplot(5,3,[10:12])
% surf(1:7,1:4,zeros(4,7),v(:,1:2:end)');
plot(1:6,v(1:2:end,:)');
shrinkplot
% view([90 90])
xlabel('Mode')
xticks(1:6)
ylabel('Participation')
title('X Motion Mode Participation')
legend {Camera 1} {Camera 2} {Camera 3}
 legend('Location','bestoutside')

subplot(5,3,[13:15])
% surf(1:7,1:4,zeros(4,7),v(:,2:2:end)');
plot(1:6,v(2:2:end,:)');
% view([90 90])
shrinkplot
xlabel('Mode')
xticks(1:6)
ylabel('Participation')
title('Y Motion Mode Participation')
legend {Camera 1} {Camera 2} {Camera 3}
 legend('Location','bestoutside')
SingularValues.(string(subscr(ipt)))=diag(s);
Results.(string(subscr(ipt))).u=u;
Results.(string(subscr(ipt))).s=s;
Results.(string(subscr(ipt))).v=v;
% plot(1:length(lambda),sqrt(lambda))

end
%% Rank 2 Approximation
for ipt=1:4;
for aprank=1:6;
    figure(9) 
    clf
    figure(10) 
    clf

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

%        %% Y
%         figure(9)
%     
%         plot(1:(length(y)),y,'k'+string(style(era))); hold on
%         xlabel('Frame')
%         ylabel('Normalized Displacement (pixels)')
% %         sgtitle('Y Displacement')
%         grid on 
        %
        %% X
        figure(9)
        
        plot(1:(length(x)),x,'k'+string(style(era))); hold on
        xlabel('Frame')
        ylabel('Normalized Displacement (pixels)')
       
        grid on
        %%
    end
%     % Y
%         figure(9)
%  
%         c=0;
%             v={{'r-'};{'r.'};{'r-.'}};
%             for o1=2:2:6;
%                 c=c+1;
%               
%                 plot(1:201,LRank(:,o1),string((v(c))))
%             end
%         xlim([0 201])
%     
%         legend 1 2 3 1R 2R 3R  
%         legend('Location','bestoutside')
%         title('Motion '+string(ipt)+' - Y Reconstruction')
%         xlabel('Time Frame')
%         ylabel('Reconstructed Displacement (px)')
        %
       %% X 
        figure(9)
 
        c=0;
            v={{'r-'};{'r.'};{'r-.'}};
            for o1=1:2:5;
                c=c+1;
              
                plot(1:201,LRank(:,o1),string((v(c))))
            end
        xlim([0 201])
    
        legend 1 2 3 1R 2R 3R  
        legend('Location','bestoutside')
         title('Motion '+string(ipt)+' - X Reconstruction')
        xlabel('Time Frame')
        ylabel('Reconstructed Displacement (px)')
       %%
       

set(gcf, 'Position', get(0, 'Screensize'));
 F(img) = getframe(gcf);
              img=img+1;
end
writerObj = VideoWriter('X'+string(era)+'.avi');
  writerObj.FrameRate = 1;
  % set the seconds per image
% open the video writer
open(writerObj);
% write the frames to the video
for i=1:length(F)
    % convert the image to a frame
    frame = F(i) ;    
    writeVideo(writerObj, frame);
end
% close the writer object
close(writerObj);

end




% % for aprank=1:6;
% %     figure(9) 
% %     clf
% %     figure(10) 
% %     clf
% % for ipt=1:4;
% %     u=Results.(string(subscr(ipt))).u;
% %     s=Results.(string(subscr(ipt))).s;
% %     v=Results.(string(subscr(ipt))).v;
% %     
% %     
% %    
% %     LRankX=u(:,1:aprank)*s(1:aprank,1:aprank)*v(:,1:aprank).';
% %     
% %    for oo=1:size(LRankX,2)
% %         LRank(:,oo)=LRankX(:,oo)./max(abs(LRankX(:,oo)));
% %    end
% %     for era=1:3;
% %          %% Removing DC Offset from Data (due to camera movement)
% %         x=detrend(storedpoints.(string(Cam(era))).(string(subscr(ipt)))(1,:));
% %         y=detrend(storedpoints.(string(Cam(era))).(string(subscr(ipt)))(2,:));
% % 
% %         if era==3;
% %         x=detrend(storedpoints.(string(Cam(era))).(string(subscr(ipt)))(2,:));
% %         y=detrend(storedpoints.(string(Cam(era))).(string(subscr(ipt)))(1,:));
% %         
% %         end
% %         
% %         subplot(2,2,ipt)
% %         %% clipping time histories 
% %         if ipt==1 && era==2;
% %             x=x(50:250);
% %             y=y(50:250);
% %         elseif ipt==2 && era~=2
% %             x=x(99:299);
% %             y=y(99:299);
% %         elseif ipt==3 && era==2;
% %             x=x(31:231);
% %             y=y(31:231);
% %         elseif ipt==3 && era==3;
% %             x=x(72:272);
% %             y=y(72:272);
% %         elseif ipt==4 && era==2;
% %             x=x(9:209);
% %             y=y(9:209);
% %         else
% %             x=x(1:201);
% %             y=y(1:201);
% %         
% %         end
% %         
% %         x=x./max(abs(x));
% %         y=y./max(abs(y));
% % 
% %        
% %         figure(9)
% %         subplot(2,2,ipt)
% %         plot(1:(length(y)),y,'k'+string(style(era))); hold on
% %         xlabel('Frame')
% %         ylabel('Normalized Displacement (pixels)')
% %         sgtitle('Y Displacement')
% %         grid on 
% %         
% %         
% %         figure(10)
% %         subplot(2,2,ipt)
% %         plot(1:(length(x)),x,'k'+string(style(era))); hold on
% %         xlabel('Frame')
% %         ylabel('Normalized Displacement (pixels)')
% %         sgtitle('X Displacement')
% %     end
% %     
% %         figure(9)
% %         subplot(2,2,ipt)
% %         c=0;
% %             v={{'r-'};{'r.'};{'r-.'}};
% %             for o1=2:2:6;
% %                 c=c+1;
% %               
% %                 plot(1:201,LRank(:,o1),string((v(c))))
% %             end
% %         xlim([0 201])
% %         sgtitle('Y Reconstruction')
% %         legend 1 2 3 1R 2R 3R  
% %         legend('Location','bestoutside')
% %         title('Motion '+string(ipt))
% %         xlabel('Time Frame')
% %         ylabel('Reconstructed Displacement (px)')
% %         
% %         figure(10)
% %         subplot(2,2,ipt)
% %         c=0;
% %             xlim([0 201])
% %             for o1=1:2:5;
% %                 c=c+1;
% %             plot(1:201,LRank(:,o1),string((v(c))))
% %             end
% %     
% %         sgtitle('X Reconstruction')
% %         legend 1 2 3 1R 2R 3R 
% %         legend('Location','bestoutside')
% %         title('Motion '+string(ipt))
% %         xlabel('Time Frame')
% %         ylabel('Reconstructed Displacement (px)')
% %         F(img) = getframe(gcf);
% %               img=img+1;
% % end
% % % mkdir('Rank'+string(aprank)+'figures')
% % % cd('Rank'+string(aprank)+'figures')
% % % for ff=9:10;
% % %     figure(ff)
% % % set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
% % % saveas(gcf,'Rank'+string(aprank)+'figure'+string(ff)+'.png')
% % % end
% % 
% % %% the different values of the v' matrix represent the modal contributions to each degree of freedom 
% % % cd ..
% % end