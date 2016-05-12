% sippi_forward_traveltime_example: Different examples of travel time
%      computation
%
% See also: sippi_forward_traveltime
%
%% load some data
clear all;close all
rng(1)
D=load('AM13_data.mat');

D2=D;
D.S(352:end,:)=D2.R(352:end,:);
D.R(352:end,:)=D2.S(352:end,:);

%% plot data
%figure(1);clf,
%figure(1);clf;
%for i=1:size(D.S,1);
%    plot(D.S(i,1),D.S(i,2),'r*');
%    hold on
%    plot(D.R(i,1),D.R(i,2),'go');
%    plot([D.S(i,1) D.R(i,1)],[D.S(i,2) D.R(i,2)],'k-');
%    axis image;
%    axis([-1 6 0 13]);set(gca,'ydir','reverse')
%    drawnow;
%end

% SETUP DATA
id=1;
data{id}.d_obs=D.d_obs;
data{id}.d_std=D.d_std;


%% DEFINE PRIOR
im=1;
prior{im}.type='FFTMA';
prior{im}.name='Velocity (m/ns)';
prior{im}.Va='.0003 Sph(6,90,.33)';
prior{im}.m0=0.10;
dx=0.15;
prior{im}.x=[-2:dx:7];
prior{im}.y=[-2:dx:13];
prior{im}.cax=[.04 .18];
%d_target=[randn(1,100)*.003+0.11 randn(1,100)*.003+0.16];
%prior{im}.d_target=d_target;
prior{im}.Va='.0001 Sph(6,90,.33)';
prior{im}.Va='.0001 Sph(6,90,.33)';
prior{im}.m0=0.10;

%% compute t in hom model
for i=1:size(D.S,1);
    dis(i)=sqrt(sum( (D.S(i,:)-D.R(i,:)).^2));
end
t_ref=dis./prior{im}.m0;


%% SETUP THE FORWARD MODEL
forward.forward_function='sippi_forw    progress_txt(is,ns);ard_traveltime';
forward.sources=D.S;
forward.receivers=D.R;
[m,prior]=sippi_prior(prior);
%m{1}=m{1}.*0+0.1;
sippi_plot_prior(prior,m);

for i=1:size(D.S,1);
for it=1:4;
    forwardi{it}=forward;
    if it==1;
        forwardi{it}.type='fd';
        %forwardi{it}.fa.doPlot=0;
        %forwardi{it}.fa.use_method=2;
        forwardi{it}.freq=0.1;
    elseif it==2
        forwardi{it}.type='eikonal';
    elseif it==3
        forwardi{it}.type='fat';
        forwardi{it}.linear=1;
        forwardi{it}.freq=0.1;
    elseif it==4
        forwardi{it}.type='fat';
        forwardi{it}.linear=0;
        forwardi{it}.freq=0.1;
        %forwardi{it}.linear_m=m{1};
    end

    L{it}=forwardi{it}.type;
for i=1:size(D.S,1);
    [d{it},forwardi{it},prior,data]=sippi_forward_traveltime(m,forwardi{it},prior,data);
    
end
%plot(t_ref,'k-')
%L{it+1}='HOM'
%hold off
%legend(L)

L{it+1}='HOM';

%%
figure(3);clf,
for it=1:length(forwardi);
    plot(d{it}{1});
    hold on
end
plot(t_ref,'k:')
hold off
legend(L)

%%
for i=1:size(D.S,1);
figure(4);
for it=2:length(forwardi);
    dd=d{it}{1}(:)-d{1}{1}(:);
    md(it)=mean(dd);
    sd(it)=std(dd);
    subplot(1,4,it-1);
    hist(d{it}{1}(:)-d{1}{1}(:),-30:.1:30);
end
