% sippi_plot_posterior_loglikelihod : plots log(L) and autorreation of log(L)
%
% Call:
%     sippi_plot_posterior_loglikelihood; % when located in an output folder
%                                         % generated by SIPPI
%
%     sippi_plot_posterior_loglikelihood(foldername); % Where 'foldername'
%                                         % is a folder generated by SIPPI
%
%
%     sippi_plot_posterior_loglikelihood(options); % where options is the
%                        % output of sippi_rejection or sippi_metropolis
%
%
%     options=sippi_plot_posterior_loglikelihood(options,prior,data,mcmc,fname);
%
%
% See also: sippi_plot_posterior
%
function options=sippi_plot_posterior_loglikelihood(options,prior,data,mcmc,fname);

cwd=pwd;
if nargin==0
    % LOAD FROM MAT FILES
    [p,matfile]=fileparts(pwd);
    [data,prior,options,mcmc]=sippi_get_posterior_data;
    %load(matfile,'prior','data','mcmc');
    options.mcmc=mcmc;
elseif nargin==1;
    if isstruct(options),
    else
        fname=options;
        cd(fname);
        load(fname);
        [data,prior,options,mcmc]=sippi_get_posterior_data;
        options.mcmc=mcmc;
    end
else
    if nargin>3
        options.mcmc=mcmc;
    end
end
if nargin<5
    try
        fname=options.txt;
    catch
        fname=mfilename;
    end
end


ic=1;
if ~isfield(options.C{ic}.mcmc,'logL')
    disp(sprintf('%s : log-likelihood data not available in mcmc or options.mcmc data structure',mfilename));
    return;
end

mcmc=options.C{1}.mcmc;

% SET DFAULT PLOTTING SETTINGS
options=sippi_plot_defaults(options);


figure(5);clf;set_paper('landscape');
set(gca,'FontSize',options.plot.axis.fontsize);


% Get index ot first logL value to plot
i1=1;    
try
    for i=1:length(prior);
        i1 = max([prior{i}.seq_gibbs.i_update_step_max i1]);
    end
end

%% PLOT log-likelihood
sippi_plot_loglikelihood(mcmc.logL);
y2=max(max(mcmc.logL));
try
    y1=min(min(mcmc.logL(:,i1:end)));
catch
    y1=min(min(mcmc.logL(:)));
end
y1_1=min(min(mcmc.logL(:)));
xlim=get(gca,'xlim');

% indicate logL = -N/2 +- sqrt(N/2)
try
    if data{id}.nois_uncorr==1;
        % GET TOTAL NUMBER OF DATA
        N=0;for id=1:length(data);N=N+length(data{id}.d_obs);end;
        hold on
        plot(xlim,[1 1].*(-N/2),'r-')
        plot(xlim,[1 1].*(-N/2-2*sqrt(N/2)),'r--')
        plot(xlim,[1 1].*(-N/2+2*sqrt(N/2)),'r--')
        hold off
        if y1>(-N/2-4*sqrt(N/2)), y1=(-N/2-4.1*sqrt(N/2));end
        if y2<(-N/2+4*sqrt(N/2)), y2=(-N/2+4.1*sqrt(N/2));end
    end
    
end

set(gca,'ylim',[y1 y2])
set(gca,'FontSize',options.plot.axis.fontsize)

set(gca,'xlim',[xlim(1) xlim(2)/20]);
print_mul(sprintf('%s_logL_start',fname),options.plot.hardcopy_types);

set(gca,'xlim',[xlim(1) xlim(2)]);
print_mul(sprintf('%s_logL',fname),options.plot.hardcopy_types);
set(gca,'ylim',[y1_1 y2])
print_mul(sprintf('%s_logL_1',fname),options.plot.hardcopy_types);

set(gca,'xscale','log')
print_mul(sprintf('%s_logL_logN',fname),options.plot.hardcopy_types);
set(gca,'xscale','linear')


%% autocorrelation
if i1<length(mcmc.logL);
    
    % Only make the autocorr analysis, if the posterior has been been
    % sampled. i1>=length(mcmc.logL) indicated annealing. 
    figure(6);clf;set_paper('landscape');
    set(gca,'FontSize',options.plot.axis.fontsize);
    
    ii=i1:length(mcmc.logL);
    % compute cross correlation 
    larr=mcmc.logL(ii)-mean(mcmc.logL(ii));
    c=conv(larr,flip(larr));
    
    c=c(length(ii):end);
    c=c./max(c);
    xc=[0:1:(length(c))-1];
    plot(xc,c,'-');grid on
  
    ic0=find(c<0);ic0=ic0(1);
    axis([0 xc(ic0)*8 -.5 1])
    hold on;
    plot([1 1].*xc(ic0),[-1 1]*.2,'-','linewidth',3);
    text(xc(ic0)+0.01*diff(get(gca,'xlim')),0.1,sprintf('Nite=%d',xc(ic0)),'FontSize',options.plot.axis.fontsize)
    hold off
    
    xlabel('iteration #')
    ylabel('autocorrelation of logL')
    print_mul(sprintf('%s_logL_autocorr',fname),options.plot.hardcopy_types)
end


cd(cwd);