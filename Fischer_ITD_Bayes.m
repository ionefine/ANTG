function Fischer_ITD_Bayes

% A and w define the sinusoidal tranformation from angle to ITD:
% ITD = A*sin(theta*w)
A = 260;
w = 0.0143;
sigma = 23.3; % Width of Gaussian prior degrees

N = 100; % number of neurons
sigman = 45; % tuning width of neurons (deg, made up)
Amax = 1; % maximum firing rate of neurons (doesn't matter)

%% Example for one direction

theta = 45; % direction of auditory stimulus
mu = randn(1,N)*sigma; % vector of neuron's preferred direction (centered and biased toward zero)

% Get the tectum  model responses (complex numbers representing vectors
% pointing in preferred direction of each neuron
z = tectumModel(theta,A,w,mu,sigma,sigman,Amax);

% Estimated direction is the mean of these vectors
estTheta = z2theta(mean(z));

% Show the population response vectors, real vector and estimated vector
figure(1); 
clf; hold on;
plot([zeros(size(z));z],'k-');
h(1) = plot([0,exp(sqrt(-1)*theta*pi/180)],'r-','LineWidth',2);
h(2) = plot([0,exp(sqrt(-1)*estTheta*pi/180)],'g-','LineWidth',2);
legend(h,{'real','estimated'},'Location','NorthWest');
axis equal

%% Loop through multiple directions

targetDirList = -150:30:150;
nReps = 1000;

for i = 1:length(targetDirList)
    theta = targetDirList(i);
    
    % preferred directions for each neuron
    mu = randn(nReps,N)*sigma;
    
    z = tectumModel(theta,A,w,mu,sigma,sigman,Amax);
    
    thetaEst = z2theta(mean(z,2));
    
    meanEst(i) = mean(thetaEst);
    sdEst(i) = std(thetaEst);
    
end

figure(2);
clf; hold on;
plot(targetDirList,targetDirList,'k-');
errorbar(targetDirList,meanEst,sdEst,'b','LineStyle','none');
plot(targetDirList,meanEst,'b-');
xlabel('Target direction (deg)');
ylabel('Estimated direction (deg)');
set(gca,'XLim',[-160,160]);
set(gca, 'XLim', [-160 160], 'XTick',targetDirList, ...
    'YTick',targetDirList);
axis equal
grid on

end

function z = tectumModel(theta,A,w,mu,sigma,sigman,Amax)

ITDn = A*sin(w*mu); % ITD for the preferred direction of each neuron
ITDstim = A*sin(w*theta); % ITD of the actual direction of stimulus

% response of each neuron: Gaussian evalulated at ITDstim centered at ITDn
R = Amax*exp(-(ITDstim-ITDn).^2/(2*sigman^2));

% response transfered to vector in complex domain
z = R.*exp(sqrt(-1)*mu*pi/180);
end

function theta = z2theta(z)

theta = angle(z);
theta(real(z)<0 & imag(z)>=0) = theta(real(z)<0 & imag(z)>0) +pi;
theta(real(z)<0 & imag(z)<0) = theta(real(z)<0 & imag(z)<0) -pi;

theta = theta*180/pi;

end
