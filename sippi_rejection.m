function options=sippi_rejection(data,prior,forward,options)
% sippi_rejection Rejection sampling
%
% Call :
%     options=sippi_rejection(data,prior,forward,options)
%
% input arguments
%
%   options.mcmc.i_plot
%   options.mcmc.nite     % maximum number of iterations
%   options.mcmc.logLmax [def=1]; % Maximum possible log-likelihood value
%
%   options.mcmc.rejection_normalize_log = log(options.mcmc.Lmax)
%
%   options.mcmc.adaptive_rejection=1, adaptive setting of maximum likelihood
%                  (def=[0])
%                  At each iteration logLmax will be set if log(L(m_cur)=>options.mcmc.logLmax
%
%
%   options.mcmc.max_run_time_hours = 1; % maximum runtime in hours
%                                        % (overrides options.mcmc.nite if needed)
%
%   options.mcmc.T = 1; % Tempering temperature. T=1, implies no tempering
%
% See also sippi_metropolis
%
%

% USE LESS DATA

% USE HIGHER UNCERTAINTY

% USE ADAPTIVE NORMALIZATION


%% NAME
options.null='';
if ~isfield(options,'txt');options.txt='';end
if length(options.txt)>0
    options.txt=sprintf('%s_sippi_rejection_%s',datestr(now,'YYYYmmdd_HHMM'),options.txt);
else
    options.txt=sprintf('%s_sippi_rejection',datestr(now,'YYYYmmdd_HHMM'));
end


%% INITIALIZE ASC FILE
start_dir=pwd;
try;
    mkdir(options.txt);
    cd(options.txt);
    addpath(['..',filesep])
    
    % copy training image file if used    
    for im=1:length(prior);
        if isfield(prior{im},'ti')
        if ischar(prior{im}.ti)
        try
            if isunix               
                system(sprintf('cp ..%s%s . ',filesep,prior{im}.ti));
            else
                cmd=sprintf('copy ..%s%s ',filesep,prior{im}.ti);
                system(cmd);
            end
        end
        end
        end
    end
end
for im=1:length(prior)
    filename_asc{im}=sprintf('%s_m%d%s',options.txt,im,'.asc');
    sippi_verbose(filename_asc{im},2);
    fid=fopen(filename_asc{im},'w');
    fclose(fid);
end
filename_mat=[options.txt,'.mat'];

mcmc.null='';
if isfield(options,'mcmc');mcmc=options.mcmc;end

if ~isfield(mcmc,'T');mcmc.T=1;end


if ~isfield(mcmc,'i_plot');mcmc.i_plot=500;end
if ~isfield(mcmc,'adaptive_rejection');mcmc.adaptive_rejection=0;end
if mcmc.adaptive_rejection==1
    if ~isfield(mcmc,'logLmax')&~isfield(mcmc,'Lmax')
        mcmc.logLmax=-inf;1e+300;
    end
end
if ~isfield(mcmc,'nite');mcmc.nite=1000;end
if ~isfield(mcmc,'logLmax');
    if mcmc.adaptive_rejection==1;
        mcmc.logLmax=-100;
    else
        mcmc.logLmax=1;
    end
end
if isfield(mcmc,'Lmax');mcmc.Lmax=exp(mcmc.Lmax);end
if ~isfield(mcmc,'rejection_normalize_log');mcmc.rejection_normalize_log = log(mcmc.logLmax);end

prior=sippi_prior_init(prior);
iacc=0;
t0=now;

mcmc.logL=zeros(1,mcmc.nite);

if isfield(mcmc,'max_run_time_hours');
    mcmc.time_end = now + mcmc.max_run_time_hours/24;
else
    mcmc.time_end = Inf;
end

sippi_verbose(sprintf('%s : STARTING rejection sampler in %s',mfilename,options.txt),-2)
for i=1:mcmc.nite
    
    m_propose = sippi_prior(prior);
    if isfield(forward,'forward_function');
        [d,forward,prior,data]=feval(forward.forward_function,m_propose,forward,prior,data);
    else
        [d,forward,prior,data]=sippi_forward(m_propose,forward,prior,data);
    end
    [logL,L,data]=sippi_likelihood(d,data);
    
    
    %logLPacc = logL-mcmc.rejection_normalize_log;
    logLPacc = (1./mcmc.T).*(logL-mcmc.rejection_normalize_log);
    
    if log(rand(1))<logLPacc
        sippi_verbose(sprintf('%s : %06d/%06d ACCEPT logLPacc=%4.1g, Pacc=%4.1g',mfilename,i,mcmc.nite,logLPacc,exp(logLPacc)),1);
        iacc=iacc+1;
        mcmc.logL(iacc)=logL;
        for im=1:length(prior)
            fid=fopen(filename_asc{im},'a+');
            fprintf(fid,' %10.7g ',m_propose{im}(:));
            fprintf(fid,'\n');
            fclose(fid);
        end
        
    end
    if (i/mcmc.i_plot)==round(i/mcmc.i_plot)
        
        [t_end_txt,t_left_seconds]=time_loop_end(t0,i,mcmc.nite);
        nite=mcmc.nite;
        
        % time left if using
        if ~isinf(mcmc.time_end)
            t_left_seconds_time_end = 3600*24*(mcmc.time_end-now);
            if (t_left_seconds_time_end<t_left_seconds)
                t_end_txt = datestr(mcmc.time_end);%'time_limit';
                % compute reamining number of iterations
                time_per_ite = ((now-t0)/i);
                i_left = (mcmc.time_end-now)/time_per_ite;
                nite = i+ceil(i_left);
            end
        end
        sippi_verbose(sprintf('%s : %06d/%06d (%10s) nacc=%06d - %s',mfilename,i,nite,t_end_txt,iacc),-1)
        
    end
    if ((i/(10*mcmc.i_plot))==round( i/(10*mcmc.i_plot) ))
        save(filename_mat)
    end
    
    if (mcmc.adaptive_rejection==0)
        % Traditional rejection sampling
        
    else
        % Adaptive rejection sampling
        if logL>mcmc.rejection_normalize_log
            sippi_verbose(sprintf('%s : i=%06d,  new log(maxL) = %g (%g)',mfilename,i,logL,mcmc.rejection_normalize_log))
            mcmc.rejection_normalize_log=logL;
        end
        
    end
    
    if (now>mcmc.time_end);
        break
        %else
        %    disp(sprintf(' %s - %s',datestr(now),datestr(mcmc.time_end)))
    end
    
    
end
mcmc.logL=mcmc.logL(1:iacc);

options.mcmc=mcmc;

save(filename_mat)
sippi_verbose(sprintf('%s : DONE rejection sampling in %s',mfilename,options.txt),-2)


%%
cd(start_dir);




end
