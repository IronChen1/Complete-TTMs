%% plot_TTM_M0.m
% Plot Kerr TTM spectra for m=0.
% 绘制 m=0 的 Kerr TTM 频率 omega 和分离常数 lambda。

clc; clear; close all;

%% ================= Settings / 设置 =================
mTarget = 0;
omegaScale = 'linear';      % 'linear' or 'log'
plotLambda = true;
exportFigures = false;
resolution = 250;
markerSize = 20;

% Repository paths / 仓库路径
scriptDir = fileparts(mfilename('fullpath'));    % Codes/MATLAB
repoDir   = fileparts(fileparts(scriptDir));     % repository root
dataDir   = fullfile(repoDir,'Data');
figDir    = fullfile(repoDir,'Figures');

if exportFigures && ~isfolder(figDir), mkdir(figDir); end

%% ================= Colormap / 颜色表 =================
CM = [0.3686 0.3098 0.6353; 0.2536 0.4588 0.7059; 0.2641 0.6091 0.7098;
      0.4000 0.7608 0.6471; 0.5804 0.8314 0.6444; 0.7477 0.8980 0.6275;
      0.9020 0.9608 0.5961; 0.9673 0.9869 0.6980; 0.9987 0.9595 0.6810;
      0.9961 0.8784 0.5451; 0.9935 0.7477 0.4353; 0.9804 0.5974 0.3412;
      0.9569 0.4275 0.2627; 0.8758 0.3046 0.2941; 0.7634 0.1634 0.2928;
      0.6196 0.0039 0.2588];

%% ================= Main loop / 主循环 =================
for nInf = 1:4

    fname = fullfile(dataDir,...
        sprintf('TTM_merged_Ninf%d_M%d.mat',nInf,mTarget));
    C = loadTTM(fname);

    use3D = ismember(nInf,[2,3]);   % n_inf=2,3 use ell as z-axis

    %% ===================== omega =====================
    fig = figure('Color','w'); hold on;

    for j = size(C,1):-1:1
        id = C{j,1};
        ell = id(1); m = id(2);
        M = C{j,2};
        if isempty(M), continue; end

        a = real(M(:,1));
        w = M(:,2);

        [x,y,valid,xlab,xscale,yscale] = omegaXY(w,nInf,omegaScale);

        if use3D
            z = ell*ones(sum(valid),1);
            sc = scatter3(x(valid),y(valid),z,markerSize,a(valid),'filled');
        else
            sc = scatter(x(valid),y(valid),markerSize,a(valid),'filled');
        end

        setDataTip(sc,xlab,'$-\Im(\omega)=$',ell,m,nInf);
    end

    xlabel(xlab,'Interpreter','latex');
    ylabel('$-\Im(\omega)$','Interpreter','latex');

    if use3D
        zlabel('$\ell$','Interpreter','latex');
        set(gca,'ZDir','reverse');
        setEllTicks(C);
        view([-13 30]);
    end

    set(gca,'XScale',xscale,'YScale',yscale);
    styleAxes(CM);

    hold off;

    if exportFigures
        tag = '';
        if strcmpi(omegaScale,'log'), tag = '_Log'; end
        exportgraphics(fig,fullfile(figDir,...
            sprintf('Fig_TTM%s_Ninf%d_M0.png',tag,nInf)),...
            'Resolution',resolution);
    end


    %% ===================== lambda =====================
    if plotLambda

        fig = figure('Color','w'); hold on;

        for j = size(C,1):-1:1
            id = C{j,1};
            ell = id(1); m = id(2);
            M = C{j,2};
            if isempty(M), continue; end

            a = real(M(:,1));
            lam = M(:,3);

            x = real(lam);
            y = -imag(lam);
            valid = isfinite(x) & isfinite(y);

            if use3D
                z = ell*ones(sum(valid),1);
                sc = scatter3(x(valid),y(valid),z,markerSize,a(valid),'filled');
            else
                sc = scatter(x(valid),y(valid),markerSize,a(valid),'filled');
            end

            setDataTip(sc,'$\Re(\lambda)=$','$-\Im(\lambda)=$',ell,m,nInf);
        end

        xlabel('$\Re(\lambda)$','Interpreter','latex');
        ylabel('$-\Im(\lambda)$','Interpreter','latex');

        if use3D
            zlabel('$\ell$','Interpreter','latex');
            set(gca,'ZDir','reverse');
            setEllTicks(C);
            view([-13 30]);
        end

        styleAxes(CM);
        hold off;

        if exportFigures
            exportgraphics(fig,fullfile(figDir,...
                sprintf('Fig_TTM_Lambda_Ninf%d_M0.png',nInf)),...
                'Resolution',resolution);
        end
    end
end

fprintf('TTM m=0 plotting completed. / m=0 绘图完成。\n');


%% ================= Local functions / 局部函数 =================

function C = loadTTM(fname)
% Load TTM cell data / 读取 TTM cell 数据
    if ~isfile(fname), error('File not found: %s',fname); end
    S = load(fname);
    f = fieldnames(S);
    C = [];
    for k = 1:numel(f)
        if iscell(S.(f{k}))
            C = S.(f{k});
            break;
        end
    end
    if isempty(C), error('No TTM cell data found in %s',fname); end
end


function [x,y,valid,xlab,xscale,yscale] = omegaXY(w,nInf,mode)
% Omega coordinates / omega 坐标设置
    y = -imag(w);

    if strcmpi(mode,'linear')
        x = real(w);
        xlab = '$\Re(\omega)$';
        xscale = 'linear';
        yscale = 'linear';
        valid = isfinite(x) & isfinite(y);
        return;
    end

    % Log mode / 对数模式
    yscale = 'log';

    if nInf == 1
        x = -real(w);
        xlab = '$-\Re(\omega)$';
        xscale = 'log';
        valid = x>0 & y>0 & isfinite(x) & isfinite(y);

    elseif nInf == 3
        % Special: Re(omega) remains linear.
        % 特殊：n_inf=3 的实部不取对数。
        x = real(w);
        xlab = '$\Re(\omega)$';
        xscale = 'linear';
        valid = y>0 & isfinite(x) & isfinite(y);

    else
        x = real(w);
        xlab = '$\Re(\omega)$';
        xscale = 'log';
        valid = x>0 & y>0 & isfinite(x) & isfinite(y);
    end
end


function styleAxes(CM)
% Common style / 公共图形格式
    colormap(CM);
    c = colorbar('northoutside');
    c.Label.Interpreter = 'latex';
    c.Label.String = '$a$';
    c.Label.FontSize = 18;

    clim([0,1]);
    set(gca,'FontName','Times New Roman','FontSize',18);
    grid on; box on;
end


function setEllTicks(C)
% Set ell ticks for 3D plots / 设置三维图的 ell 刻度
    ellList = sort(cellfun(@(x)x(1),C(:,1)));
    step = 4;

    ticks = intersect(ellList(1):step:ellList(end),ellList);

    set(gca,'ZTick',ticks);
    set(gca,'ZTickLabel',arrayfun(@num2str,ticks,'UniformOutput',false));
end


function setDataTip(sc,xlab,ylab,ell,m,nInf)
% Customize DataTip / 定制 DataTip
    try
        dtt = sc.DataTipTemplate;
        dtt.Interpreter = 'latex';
        rows = dtt.DataTipRows;

        % X and Y
        rows(1).Label = xlab;
        rows(2).Label = ylab;

        % Remove Size/Z rows; keep Color(a)
        % 删除 Size/Z，仅保留颜色 a。
        keep = true(numel(rows),1);
        for r = 1:numel(rows)
            s = lower(strrep(rows(r).Label,' ',''));
            if contains(s,'size') || contains(s,'z')
                keep(r) = false;
            end
        end
        rows = rows(keep);

        % Color -> n_inf,a
        if numel(rows)>=3
            rows(3).Label = sprintf('$n_{\\infty}=%d,\\,a=$',nInf);
        end

        ellRow = dataTipTextRow('$\ell=$',repmat(ell,numel(sc.XData),1));
        mRow   = dataTipTextRow('$m=$',repmat(m,numel(sc.XData),1));

        try, ellRow.Interpreter='latex'; end
        try, mRow.Interpreter='latex'; end

        dtt.DataTipRows = [rows; ellRow; mRow];
    catch
    end
end