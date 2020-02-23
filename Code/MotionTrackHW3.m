showtracking='ees';
% initializing frame 1 regions of interest for each video
% this allows the algorithm to lock onto something and track it
regions.Camera1.a=[320 220 20 50];
regions.Camera1.b=[315 290 25 50];
regions.Camera1.c=[320 280 20 50];
regions.Camera1.d=[380 270 20 15];

regions.Camera2.a=[260 265 25 50];
regions.Camera2.b=[295 335 35 50];
regions.Camera2.c=[238 285 25 50];
regions.Camera2.d=[250 255 30 40];

regions.Camera3.a=[310 260 75 23];
regions.Camera3.b=[340 245 75 23];
regions.Camera3.c=[350 210 75 23];
regions.Camera3.d=[350 210 20 30];

for ipt=1:4;    % looping over all of the test cases 

    for era=1:3;    % looping over each camera 
    
    
        
    if showtracking=='yes';
    figure
    hold on;
    end

    currset=(string(Cam(era)))+(','+string(subscr(ipt)));   % the test and camera as a string for labelling
    If=Camera.(string(Cam(era))).(string(subscr(ipt)))(:,:,1);  % getting the frame from the grayscaled matrix of images

    if showtracking=='yes';
    imshow(If)
    F(img) = getframe(gcf); % saving frame 
              img=img+1;    % increment counter
    end

    %%
    reg=regions.(string(Cam(era))).(string(subscr(ipt)))(1,:);  % selecting region of interest to be tracked
%%

    regionsObj = detectMSERFeatures(If,'ROI',reg);  % detecting features (IDK how this works lol) 

    [features, validPtsObj] = extractFeatures(If, regionsObj);  % this is some magic 

    if showtracking=='yes';
        
        If2=insertShape(If,'Rectangle',reg,'Color','red');
        imshow(If2); hold on;
        plot(regionsObj,'showPixelList',true,'showEllipses',false);
        title(currset)
       
        F(img) = getframe(gcf);
              img=img+1;
    end

        trackedpoints=validPtsObj.Location;     % grabbing the points that are valid to track them next frame
        tracker = vision.PointTracker('MaxBidirectionalError',5,'NumPyramidLevels',16); % defining the tracker properties
        initialize(tracker,trackedpoints,If);           % initializing tracker

        [~,~,m]=size(Camera.(string(Cam(era))).(string(subscr(ipt))));  % getting the size of the image
        title(currset)  % setting title of plot
        c=0;
        for im=1:1:m;   % for all of the images 
            c=c+1;
              Icurr=Camera.(string(Cam(era))).(string(subscr(ipt)))(:,:,im);    % this is the current image
              
              if showtracking=='yes';
              imshow(Icurr);        % show the current image
              end
              
              [points,validity,score] = tracker(Icurr); % gimme them points, computer friend

              if sum(validity)<=2 || (ipt==4 &&c==15) || (ipt==2 &&c==25); %if you lost track, recapture the points please
                  
                  reg=([xavg(im-1)- reg(3)/2  yavg(im-1)-reg(4)/2 reg(3) reg(4)]);  %look here, computer friend
                  if  era==3 || sum(validity)<=1 ;
                  reg=([xavg(im-1)- reg(3)/2  yavg(im-1)-reg(4)/2 reg(3) reg(4)*1.12]); %broaden your perspective 
                  end
                    regionsObj = detectMSERFeatures(Icurr,'ROI',reg,'MaxAreaVariation',1);  % get the regions

                    [features, validPtsObj] = extractFeatures(Icurr, regionsObj);   % extract the features
                    If2=insertShape(Icurr,'Rectangle',reg,'Color','red');   %inserts rectangle around ROI
                    
                    if showtracking=='yes';
                    imshow(If2); hold on;   % show the current image

                    plot(regionsObj,'showPixelList',true,'showEllipses',false); % show tracked points
                    F(img) = getframe(gcf); % save frame
                    img=img+1;    % increment frame counter
                    
                    
                    end     
                    
                    trackedpoints=validPtsObj.Location; % getting points from object

                    tracker = vision.PointTracker('MaxBidirectionalError',2,'NumPyramidLevels',14); %redefining tracker properties
                    initialize(tracker,trackedpoints,Icurr);    %initializing new tracker
                    [points,validity,score] = tracker(Icurr); % tracking points
                c=0; % killing counter for reacquisition (tracker reacquires periodically for high noise/rotation cases)
              end
              
              xavg(im)=sum(points(:,1).*score)./sum(score); % acquiring the average point x location for this frame
                                                       % taking the first
                                                       % moment with the
                                                       % statistical score
                                                       % to weight msrments

              yavg(im)=sum(points(:,2).*score)./sum(score); % acquiring the average point y location for this frame

              reg=regions.(string(Cam(era))).(string(subscr(ipt)))(1,:); % defining the ROI again for next frame

              out = insertMarker(Icurr,points(validity, :),'+');    % display the tracked points on the current image
        
              if showtracking=='yes';
              imshow(out); drawnow
              F(img) = getframe(gcf);
              img=img+1;
              end
              
        end
        
        storedpoints.(string(Cam(era))).(string(subscr(ipt)))=[xavg;yavg]; % saving the average points in a structure for this test and camera angle
                        % this will be assembled into X[mxn] later such
                        % that the SVD can be computed
            
        plot(xavg,yavg)
        title(currset)
        
        F(img) = getframe(gcf);
        img=img+1;
    end
    
end
writerObj = VideoWriter('myVideo.avi');
  writerObj.FrameRate = 10;
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

