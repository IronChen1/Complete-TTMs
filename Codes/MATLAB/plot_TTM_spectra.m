%% plot_TTM_spectra.m
% Plot Kerr TTM frequencies and separation constants.
% 绘制 Kerr TTM 的频率 omega 和分离常数 lambda。

clc; clear; close all;

%% ====================== Settings / 设置 ======================
mTarget = 1;
omegaScale = 'linear';       % 'linear' or 'log'
plotLambda = true;
exportFigures = false;
resolution = 250;
markerSize = 20;

% Repository paths / 仓库路径
scriptDir = fileparts(mfilename('fullpath'));      % Codes/MATLAB
repoDir   = fileparts(fileparts(scriptDir));       % repository root
dataDir   = fullfile(repoDir,'Data');
figDir    = fullfile(repoDir,'Figures');

if exportFigures && ~isfolder(figDir), mkdir(figDir); end

%% ====================== Colormap / 颜色表 =====================
CM = [0.3686 0.3098 0.6353; 0.2536 0.4588 0.7059; 0.2641 0.6091 0.7098;
      0.4000 0.7608 0.6471; 0.5804 0.8314 0.6444; 0.7477 0.8980 0.6275;
      0.9020 0.9608 0.5961; 0.9673 0.9869 0.6980; 0.9987 0.9595 0.6810;
      0.9961 0.8784 0.5451; 0.9935 0.7477 0.4353; 0.9804 0.5974 0.3412;
      0.9569 0.4275 0.2627; 0.8758 0.3046 0.2941; 0.7634 0.1634 0.2928;
      0.6196 0.0039 0.2588];

%% ================= Axis ranges / 坐标范围 ====================
omegaLinearX = {[-140,3],[0,44],[-0.5e3,3300],[0,245]};
omegaLinearY = {[-140,1050],[-80,1250],[-10,9.5e4],[-120,980]};

% n_inf=1 uses -Re(omega); n_inf=3 keeps linear x.
% n_inf=1 横轴使用 -Re(omega)；n_inf=3 横轴仍为线性。
omegaLogX = {[3.261,2.207e2],[0.97871,48.572],[-0.5e3,3300],[5.9136,345.03]};
omegaLogY = {[1.3359,1.0927e3],[2.2824,3.5008e3],[],[0.99127,1.205e3]};

%% ====================== Main loop / 主循环 ===================
for nInf = 1:4
    fname = fullfile(dataDir, ...
        sprintf('TTM_merged_Ninf%d_M%d.mat',nInf,mTarget));
    C = loadTTM(fname);

    %% -------------------- omega --------------------
    fig = figure('Color','w'); hold on;

    for j = size(C,1):-1:1
        id = C{j,1};
        ell = id(1); m = id(2);
        M = C{j,2};
        if isempty(M), continue; end

        a = real(M(:,1));
        w = M(:,2);

        [x,y,valid,xlab,xscale,yscale] = omegaXY(w,nInf,omegaScale);

        sc = scatter(x(valid),y(valid),markerSize,a(valid),'filled');
        setDataTip(sc,xlab,'$-\Im(\omega)=$',ell,m,nInf);

        if nInf~=3 && (j==1 || j==size(C,1))
            try, datatip(sc,'DataIndex',sum(valid),'Location','southeast'); end
        end
    end

    xlabel(xlab,'Interpreter','latex');
    ylabel('$-\Im(\omega)$','Interpreter','latex');
    set(gca,'XScale',xscale,'YScale',yscale);

    styleAxes(CM);

    if strcmpi(omegaScale,'linear')
        xlim(omegaLinearX{nInf}); ylim(omegaLinearY{nInf});
        tag = '';
    else
        if ~isempty(omegaLogX{nInf}), xlim(omegaLogX{nInf}); end
        if ~isempty(omegaLogY{nInf}), ylim(omegaLogY{nInf}); end
        tag = '_Log';
    end

    hold off;

    if exportFigures
        exportgraphics(fig,fullfile(figDir, ...
            sprintf('Fig_TTM%s_Ninf%d_M%d.png',tag,nInf,mTarget)), ...
            'Resolution',resolution);
    end

    %% -------------------- lambda -------------------
    if plotLambda
        fig = figure('Color','w'); hold on;

        for j = size(C,1):-1:1
            id = C{j,1};
            ell = id(1); m = id(2);
            M = C{j,2};
            if isempty(M), continue; end

            a = real(M(:,1));
            lam = M(:,3);                  % lambda is column 3 / lambda 为第3列

            x = real(lam);
            y = -imag(lam);
            valid = isfinite(x) & isfinite(y);

            sc = scatter(x(valid),y(valid),markerSize,a(valid),'filled');
            setDataTip(sc,'$\Re(\lambda)=$','$-\Im(\lambda)=$',ell,m,nInf);

            if j==1 || j==size(C,1)
                try, datatip(sc,'DataIndex',sum(valid),'Location','southeast'); end
            end
        end

        xlabel('$\Re(\lambda)$','Interpreter','latex');
        ylabel('$-\Im(\lambda)$','Interpreter','latex');
        styleAxes(CM);
        hold off;

        if exportFigures
            exportgraphics(fig,fullfile(figDir, ...
                sprintf('Fig_TTM_Lambda_Ninf%d_M%d.png',nInf,mTarget)), ...
                'Resolution',resolution);
        end
    end
end

fprintf('TTM plotting completed. / TTM 绘图完成。\n');


%% ====================== Local functions ======================

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
    if isempty(C), error('No cell data found in %s',fname); end
end


function [x,y,valid,xlab,xscale,yscale] = omegaXY(w,nInf,mode)
% Omega coordinates / omega 绘图坐标

    y = -imag(w);

    if strcmpi(mode,'linear')
        x = real(w);
        xlab = '$\Re(\omega)$';
        xscale = 'linear';
        yscale = 'linear';
        valid = isfinite(x) & isfinite(y);
        return;
    end

    yscale = 'log';

    if nInf == 1
        x = -real(w);
        xlab = '$-\Re(\omega)$';
        xscale = 'log';
        valid = x>0 & y>0 & isfinite(x) & isfinite(y);

    elseif nInf == 3
        x = real(w);
        xlab = '$\Re(\omega)$';
        xscale = 'linear';        % special / 特殊：实部不取对数
        valid = y>0 & isfinite(x) & isfinite(y);

    else
        x = real(w);
        xlab = '$\Re(\omega)$';
        xscale = 'log';
        valid = x>0 & y>0 & isfinite(x) & isfinite(y);
    end
end


function styleAxes(CM)
% Common figure style / 公共图形格式
    colormap(CM);
    c = colorbar;
    c.Label.Interpreter = 'latex';
    c.Label.String = '$a$';
    clim([0,1]);

    set(gca,'FontName','Times New Roman','FontSize',18);
    grid on; box on;
end


function setDataTip(sc,xlab,ylab,ell,m,nInf)
% Customize DataTip / 定制 DataTip
    try
        dtt = sc.DataTipTemplate;
        dtt.Interpreter = 'latex';
        rows = dtt.DataTipRows;

        rows(1).Label = xlab;
        rows(2).Label = ylab;

        % scatter default: X, Y, Size, Color
        if numel(rows)>=3, rows(3)=[]; end
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