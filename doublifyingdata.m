clc
clear all 
close all

c1.a=load('cam1_1.mat');
c1.b=load('cam1_2.mat');
c1.c=load('cam1_3.mat');
c1.d=load('cam1_4.mat');

c2.a=load('cam2_1.mat');
c2.b=load('cam2_2.mat');
c2.c=load('cam2_3.mat');
c2.d=load('cam2_4.mat');

c3.a=load('cam3_1.mat');
c3.b=load('cam3_2.mat');
c3.c=load('cam3_3.mat');
c3.d=load('cam3_4.mat');

% Doublifying the data
[xs,ys,~,nframes]=size(c1.a.vidFrames1_1)
for i=1:nframes;
Camera1.a(:,:,i)=(rgb2gray(c1.a.vidFrames1_1(:,:,:,i)));
end

[xs,ys,~,nframes]=size(c1.b.vidFrames1_2)
for i=1:nframes;
Camera1.b(:,:,i)=(rgb2gray(c1.b.vidFrames1_2(:,:,:,i)));
end

[xs,ys,~,nframes]=size(c1.c.vidFrames1_3)
for i=1:nframes;
Camera1.c(:,:,i)=(rgb2gray(c1.c.vidFrames1_3(:,:,:,i)));
end

[xs,ys,~,nframes]=size(c1.d.vidFrames1_4)
for i=1:nframes;
Camera1.d(:,:,i)=(rgb2gray(c1.d.vidFrames1_4(:,:,:,i)));
end

[xs,ys,~,nframes]=size(c2.a.vidFrames2_1)
for i=1:nframes;
Camera2.a(:,:,i)=(rgb2gray(c2.a.vidFrames2_1(:,:,:,i)));
end

[xs,ys,~,nframes]=size(c2.b.vidFrames2_2)
for i=1:nframes;
Camera2.b(:,:,i)=(rgb2gray(c2.b.vidFrames2_2(:,:,:,i)));
end

[xs,ys,~,nframes]=size(c2.c.vidFrames2_3)
for i=1:nframes;
Camera2.c(:,:,i)=(rgb2gray(c2.c.vidFrames2_3(:,:,:,i)));
end

[xs,ys,~,nframes]=size(c2.d.vidFrames2_4)
for i=1:nframes;
Camera2.d(:,:,i)=(rgb2gray(c2.d.vidFrames2_4(:,:,:,i)));
end

[xs,ys,~,nframes]=size(c3.a.vidFrames3_1)
for i=1:nframes;
Camera3.a(:,:,i)=(rgb2gray(c3.a.vidFrames3_1(:,:,:,i)));
end

[xs,ys,~,nframes]=size(c3.b.vidFrames3_2)
for i=1:nframes;
Camera3.b(:,:,i)=(rgb2gray(c3.b.vidFrames3_2(:,:,:,i)));
end

[xs,ys,~,nframes]=size(c3.c.vidFrames3_3)
for i=1:nframes;
Camera3.c(:,:,i)=(rgb2gray(c3.c.vidFrames3_3(:,:,:,i)));
end

[xs,ys,~,nframes]=size(c3.d.vidFrames3_4)
for i=1:nframes;
Camera3.d(:,:,i)=(rgb2gray(c3.d.vidFrames3_4(:,:,:,i)));
end

Camera.Camera1=Camera1;
Camera.Camera2=Camera2;
Camera.Camera3=Camera3;
save('Grayscale.mat','Camera')