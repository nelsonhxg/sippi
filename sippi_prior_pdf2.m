% sippi_prior_pdf: sampled from 2D PDF
function [m_propose,prior]=sippi_prior_pdf2(prior,m_current,ip);


if nargin<3;
    ip=1;
end

if ~isfield(prior{ip},'init')
    prior=sippi_prior_init(prior);
end

if length(prior{ip}.x)==1
    disp('XXX')
    prior{ip}.x=[1,2];
end


if ~isfield(prior{ip},'pdf')
end

if ~isfield(prior{ip},'pdf_x')
    nx=size(prior{ip}.pdf,2);
    prior{ip}.pdf_x=1:1:nx;
end

if ~isfield(prior{ip},'pdf_y')
    ny=size(prior{ip}.pdf,1);
    prior{ip}.pdf_y=1:1:ny;
end

if ~isfield(prior{ip},'p')
    prior{ip}.p=[rand(1),rand(1)];
end

perturb=1;
if nargin==1;
    perturb=0;
else
    if prior{ip}.seq_gibbs.step==1
        perturb=0;
    end
end


if perturb==0
    prior{ip}.p=[rand(1),rand(1)];
else
    p_org=prior{ip}.p;
    p=p_org+randn(1,2).*prior{ip}.seq_gibbs.step;
    p(find(p<0))=p_org(find(p<0));
    p(find(p>1))=p_org(find(p>1));
    prior{ip}.p=p;
end


% XDIM
CPDF_x=cumsum(sum(prior{ip}.pdf,1));CPDF_x=CPDF_x./max(CPDF_x(:));
ix_arr=find(CPDF_x>=prior{ip}.p(1));
ix=ix_arr(1);
ix1=max([1 ix-1]);
ix2=min([length(prior{1}.pdf_x) ix+1]);
ixx=ix1:ix2;
try
    x_sim=interp1(CPDF_x(ixx),prior{1}.pdf_x(ixx),prior{1}.p(1));
    %x_sim=interp1(CPDF_x,x,p(1));
catch
    x_sim=prior{1}.pdf_x(ix);
end

% YDIM
CPDF_y=cumsum(sum(prior{1}.pdf(:,ix),2));CPDF_y=CPDF_y./max(CPDF_y(:));
iy_arr=find(CPDF_y>=prior{1}.p(2));
iy=iy_arr(1);
iy1=max([1 iy-1]);
iy2=min([length(prior{1}.pdf_y) iy+1]);
iyy=iy1:iy2;
try
    y_sim=interp1(CPDF_y(iyy),prior{1}.pdf_y(iyy),prior{1}.p(2));
    %y_sim=interp1(CPDF_y,y,p(2));
catch
    y_sim=prior{1}.pdf_y(iy);
end

m_propose{1}=[x_sim;y_sim];
