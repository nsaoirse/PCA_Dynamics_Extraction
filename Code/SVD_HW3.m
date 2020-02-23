for ipt=1:4;
        
%% SVD 
DataRank(ipt,:)=rank(Xs.(string(subscr(ipt)))); % Computing rank
[m,n]=size(Xs.(string(subscr(ipt)))); % compute data size
mn=mean(Xs.(string(subscr(ipt))),1); % compute mean for each column
Xs.(string(subscr(ipt)))=Xs.(string(subscr(ipt)))-repmat(mn',1,201)'; % subtract mean from X
[u,s,v]=svd(Xs.(string(subscr(ipt)))/sqrt(n-1),'econ'); % perform the SVD
%% plotting everything 
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
plot(1:6,v(1:2:end,:)');
shrinkplot
xlabel('Mode')
xticks(1:6)
ylabel('Participation')
title('X Motion Mode Participation')
legend {Camera 1} {Camera 2} {Camera 3}
 legend('Location','bestoutside')

subplot(5,3,[13:15])
plot(1:6,v(2:2:end,:)');
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
end